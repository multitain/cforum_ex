# -*- coding: utf-8 -*-

class FlagPluginController < ApplicationController
  authorize_controller { authorize_forum(permission: :read?) }
  authorize_action(:unflag) { authorize_forum(permission: :moderator?) }

  def flag
    @thread, @message, @id = get_thread_w_post

    if not @message.flags['flagged'].blank?
      redirect_to cf_message_url(@thread, @message), notice: t('plugins.flag_plugin.already_flagged')
      return
    end

    respond_to do |format|
      format.html
    end
  end

  def flagging
    @thread, @message, @id = get_thread_w_post

    if not @message.flags['flagged'].blank?
      redirect_to cf_message_url(@thread, @message), notice: t('plugins.flag_plugin.already_flagged')
      return
    end

    if not %w(off-topic not-constructive duplicate custom).include?(params[:reason])
      flash[:error] = t("plugins.flag_plugin.reason_invalid")
      render :flag
      return
    end

    if params[:reason] == 'duplicate'
      if params[:duplicate_slug].blank? or not params[:duplicate_slug] =~ /^https?:\/\//
        flash[:error] = t("plugins.flag_plugin.dup_url_needed")
        render :flag
        return
      end

      @message.flags[:flagged_dup_url] = params[:duplicate_slug]

    elsif params[:reason] == 'custom'
      if params[:custom_reason].blank?
        flash[:error] = t("plugins.flag_plugin.custom_reason_needed")
        render :flag
        return
      end

      @message.flags[:custom_reason] = params[:custom_reason]
    end

    @message.flags[:flagged] = params[:reason]
    @message.flags_will_change!
    @message.save

    peon(class_name: 'NotifyFlaggedTask',
         arguments: {
           type: 'message',
           message_id: @message.message_id})

    redirect_to cf_message_url(@thread, @message), notice: t('plugins.flag_plugin.flagged')
  end

  def flagged
  end

  def unflag
    @thread, @message, @id = get_thread_w_post

    @message.flags.delete('flagged')
    @message.flags.delete('custom_reason')
    @message.flags.delete('flagged_dup_url')
    @message.flags_will_change!
    @message.save

    redirect_to cf_message_url(@thread, @message), notice: t('plugins.flag_plugin.unflagged')
  end
end

# ApplicationController.init_hooks << Proc.new do |app_controller|
#   accept_plugin = HighlightPlugin.new(app_controller)
#   app_controller.notification_center.register_hook(CfThreadsController::SHOW_THREADLIST, accept_plugin)

#   app_controller.notification_center.register_hook(UsersController::SHOWING_SETTINGS, accept_plugin)
#   app_controller.notification_center.register_hook(UsersController::SAVING_SETTINGS, accept_plugin)
# end

# eof
