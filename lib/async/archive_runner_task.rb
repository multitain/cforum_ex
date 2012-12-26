# -*- coding: utf-8 -*-

module Peon
  module Tasks
    class ArchiveRunnerTask < PeonTask
      def archive_forum(forum)
        Rails.logger.info "ArchiveRunnerTask: running archiver for forum #{forum.name}"

        max_threads  = conf('max_threads', forum, '150').to_i # max threads per forum
        max_messages = conf('max_messages_per_thread', forum, '50').to_i # max messages per thread

        # first: max messages per thread (to avoid monster threads like „Test, bitte ignorieren”)
        CfThread.transaction do
          threads = CfThread.select('threads.thread_id, COUNT(*) AS cnt').joins(:messages).where(archived: false, forum_id: forum.forum_id).group('threads.thread_id')

          threads.each do |t|
            if t.cnt.to_i > max_messages
              Rails.logger.info 'ArchiveRunnerTask: archiving thread ' + t.thread_id.to_s + ' because of to many messages'
              CfThread.connection.execute 'UPDATE threads SET archived = true WHERE thread_id = ' + t.thread_id.to_s
            end
          end
        end


        # second: max threads per forum
        CfThread.transaction do
          while CfThread.where(forum_id: forum.forum_id, archived: false).count > max_threads
            rslt = CfThread.connection.execute 'SELECT threads.thread_id, MAX(messages.created_at) AS created_at FROM threads INNER JOIN cforum.messages USING(thread_id) WHERE threads.forum_id = ' + forum.forum_id.to_s + ' AND archived = false GROUP BY threads.thread_id ORDER BY MAX(messages.created_at) ASC LIMIT 1'
            tid = rslt[0]['thread_id']

            Rails.logger.info 'ArchiveRunnerTask: archiving thread ' + tid + ' because oldest while to many threads'
            CfThread.connection.execute 'UPDATE threads SET archived = true WHERE thread_id = ' + tid
          end
        end
      end


      def work_work(args)
        # run for each forum separately
        forums = CfForum.all

        forums.each do |f|
          archive_forum(f) if conf('use_archive', f, 'no') == 'yes'
        end
      end
    end

    Peon::Grunt.instance.periodical(ArchiveRunnerTask.new, 120)
  end
end

# eof
