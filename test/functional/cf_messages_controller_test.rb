# -*- coding: utf-8 -*-

require 'test_helper'

class CfMessagesControllerTest < ActionController::TestCase
  test "show: should fail because of wrong parameters" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)

    assert_raise(CForum::NotFoundException) do
      get :show, {curr_forum: forum.slug, year: '2012', mon: 'feb', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "show: should show message in public forum" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)

    get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}

    assert_response :success
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:thread)
  end

  test "show: should not show deleted message because of anonymous" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)

    assert_raise(CForum::NotFoundException) do
      get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id, view_all: true}
    end
  end

  test "show: should not show deleted message because of permissions" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)
    user    = FactoryGirl.create(:cf_user, admin: false)

    sign_in user

    assert_raise(CForum::NotFoundException) do
      get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id, view_all: true}
    end
  end

  test "show: should not show deleted message because of admin and not view_all" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)
    user    = FactoryGirl.create(:cf_user, admin: true)

    sign_in user

    assert_raise(CForum::NotFoundException) do
      get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "show: should show deleted message because of admin and view_all" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)
    user    = FactoryGirl.create(:cf_user, admin: true)

    sign_in user

    get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id, view_all: true}

    assert_response :success
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:thread)
    assert assigns(:message).deleted
  end

  test "show: should not show deleted message because of read permissions" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_READ)

    sign_in user

    assert_raise(CForum::NotFoundException) do
      get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id, view_all: true}
    end
  end

  test "show: should not show deleted message because of write permissions" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_WRITE)

    sign_in user

    assert_raise(CForum::NotFoundException) do
      get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id, view_all: true}
    end
  end

  test "show: should not show deleted message because of moderator permissions and not view_all" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_MODERATE)

    sign_in user

    assert_raise(CForum::NotFoundException) do
      get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "show: should show deleted message because of moderator permissions" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_MODERATE)

    sign_in user

    get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id, view_all: true}

    assert_response :success
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:thread)
    assert assigns(:message).deleted
  end

  test "show: should fail in private forum because of anonymous" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)

    assert_raise(CForum::ForbiddenException) do
      get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "show: should fail in private forum because of permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)

    sign_in user

    assert_raise(CForum::ForbiddenException) do
      get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "show: should show message in private forum because of admin" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: true)

    sign_in user
    get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}

    assert_response :success
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:thread)
  end

  test "show: should show message in private forum because of read permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_READ)

    sign_in user
    get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}

    assert_response :success
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:thread)
  end

  test "show: should show message in private forum because of write permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_WRITE)

    sign_in user
    get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}

    assert_response :success
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:thread)
  end

  test "show: should show message in private forum because of moderator permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_MODERATE)

    sign_in user
    get :show, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}

    assert_response :success
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:thread)
  end


  test "show: should show new in public forum" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)

    get :new, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}

    assert_response :success
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:thread)
  end

  test "show: should not show new in private forum because of anonymous" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)

    assert_raise(CForum::ForbiddenException) do
      get :new, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "show: should not show new in private forum because of permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)

    sign_in user

    assert_raise(CForum::ForbiddenException) do
      get :new, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "show: should not show new in private forum because of read permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_READ)

    sign_in user

    assert_raise(CForum::ForbiddenException) do
      get :new, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "show: should show new in private forum because of write permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_WRITE)

    sign_in user

    get :new, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}

    assert_response :success
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:thread)
  end

  test "show: should show new in private forum because of moderator permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_MODERATE)

    sign_in user

    get :new, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}

    assert_response :success
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:thread)
  end

  test "create: should not create new message in public forum because of invalid" do
    forum = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)

    assert_no_difference 'CfMessage.count' do
      post :create, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        cf_message: {
          subject: '',
          author: 'Anaken Skywalker',
          content: 'Long live the imperator! Down with the rebellion!'
        }
      }
    end

    assert_response :success
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:thread)
    assert !assigns(:message).valid?
  end

  test "create: should create new message in public forum" do
    forum = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)

    assert_difference 'CfMessage.count' do
      post :create, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        cf_message: {
          subject: 'Long live the imperator!',
          author: 'Anaken Skywalker',
          content: 'Long live the imperator! Down with the rebellion!'
        }
      }
    end

    assert_not_nil assigns(:message)
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:thread)

    assert_redirected_to cf_message_url(assigns(:thread), assigns(:message))
  end

  test "create: should not create new message in private forum because of anonymous" do
    forum = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)

    assert_raise(CForum::ForbiddenException) do
      post :create, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        cf_message: {
          subject: 'Long live the imperator!',
          author: 'Anaken Skywalker',
          content: 'Long live the imperator! Down with the rebellion!'
        }
      }
    end
  end

  test "create: should not create new message in private forum because of permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)

    sign_in user

    assert_raise(CForum::ForbiddenException) do
      post :create, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        cf_message: {
          subject: 'Long live the imperator!',
          author: 'Anaken Skywalker',
          content: 'Long live the imperator! Down with the rebellion!'
        }
      }
    end
  end

  test "create: should create new message in private forum because of admin" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: true)

    sign_in user

    assert_difference('CfMessage.count') do
      post :create, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        cf_message: {
          subject: 'Long live the imperator!',
          author: 'Anaken Skywalker',
          content: 'Long live the imperator! Down with the rebellion!'
        }
      }
    end

    assert_not_nil assigns(:message)
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:thread)

    assert_redirected_to cf_message_url(assigns(:thread), assigns(:message))
  end

  test "create: should not create new message in private forum because of read permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_READ)

    sign_in user

    assert_raise(CForum::ForbiddenException) do
      post :create, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        cf_message: {
          subject: 'Long live the imperator!',
          author: 'Anaken Skywalker',
          content: 'Long live the imperator! Down with the rebellion!'
        }
      }
    end
  end

  test "create: should create new message in private forum because of write permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_WRITE)

    sign_in user

    assert_difference('CfMessage.count') do
      post :create, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        cf_message: {
          subject: 'Long live the imperator!',
          author: 'Anaken Skywalker',
          content: 'Long live the imperator! Down with the rebellion!'
        }
      }
    end

    assert_not_nil assigns(:message)
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:thread)

    assert_redirected_to cf_message_url(assigns(:thread), assigns(:message))
  end

  test "create: should create new message in private forum because of moderator permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_MODERATE)

    sign_in user

    assert_difference('CfMessage.count') do
      post :create, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        cf_message: {
          subject: 'Long live the imperator!',
          author: 'Anaken Skywalker',
          content: 'Long live the imperator! Down with the rebellion!'
        }
      }
    end

    assert_not_nil assigns(:message)
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:thread)

    assert_redirected_to cf_message_url(assigns(:thread), assigns(:message))
  end

  test "create: should show preview" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)

    assert_no_difference('CfMessage.count') do
      post :create, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        preview: true,
        cf_message: {
          subject: 'Long live the imperator!',
          author: 'Anaken Skywalker',
          content: 'Long live the imperator! Down with the rebellion!'
        }
      }
    end

    assert_response :success

    assert_not_nil assigns(:message)
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:thread)
    assert_not_nil assigns(:preview)
  end

  test "destroy: should not destroy because of anonymous" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)

    assert_raise(CForum::ForbiddenException) do
      delete :destroy, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "destroy: should not destroy because of permissions" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)

    sign_in user

    assert_raise(CForum::ForbiddenException) do
      delete :destroy, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "destroy: should destroy because of admin" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: true)

    sign_in user

    delete :destroy, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}

    assert_not_nil assigns(:message)
    assert_not_nil assigns(:thread)
    assert assigns(:message).deleted

    assert_redirected_to cf_message_url(assigns(:thread), assigns(:message), view_all: 'true')
  end

  test "destroy: should not destroy because of read permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_READ)

    sign_in user

    assert_raise(CForum::ForbiddenException) do
      delete :destroy, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "destroy: should not destroy because of write permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_WRITE)

    sign_in user

    assert_raise(CForum::ForbiddenException) do
      delete :destroy, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "destroy: should destroy because of moderator permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_MODERATE)

    sign_in user
    delete :destroy, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}

    assert_not_nil assigns(:message)
    assert_not_nil assigns(:thread)
    assert assigns(:message).deleted

    assert_redirected_to cf_message_url(assigns(:thread), assigns(:message), view_all: 'true')
  end


  test "restore: should not restore because of anonymous" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)

    assert_raise(CForum::ForbiddenException) do
      post :restore, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "restore: should not restore because of permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)
    user    = FactoryGirl.create(:cf_user, admin: false)

    sign_in user

    assert_raise(CForum::ForbiddenException) do
      post :restore, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "restore: should restore because of admin" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)
    user    = FactoryGirl.create(:cf_user, admin: true)

    sign_in user

    post :restore, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id, view_all: 'yes'}

    assert_not_nil assigns(:message)
    assert_not_nil assigns(:thread)
    assert !assigns(:message).deleted

    assert_redirected_to cf_message_url(assigns(:thread), assigns(:message), view_all: 'true')
  end

  test "restore: should not restore because of read permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_READ)

    sign_in user

    assert_raise(CForum::ForbiddenException) do
      post :restore, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "restore: should not restore because of write permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_WRITE)

    sign_in user

    assert_raise(CForum::ForbiddenException) do
      post :restore, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test "restore: should restore because of moderator permissions" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)
    user    = FactoryGirl.create(:cf_user, admin: false)
    group   = FactoryGirl.create(:cf_group)

    group.users << user
    cfg = CfForumGroupPermission.create!(forum_id: forum.forum_id, group_id: group.group_id, permission: CfForumGroupPermission::ACCESS_MODERATE)

    sign_in user

    post :restore, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id, view_all: 'yes'}

    assert_not_nil assigns(:message)
    assert_not_nil assigns(:thread)
    assert !assigns(:message).deleted

    assert_redirected_to cf_message_url(assigns(:thread), assigns(:message), view_all: 'true')
  end

  test 'should not show new form on archived thread' do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    CfSetting.create!(forum_id: forum.forum_id, options: {'use_archive' => 'yes'})

    assert_raise CForum::ForbiddenException do
      get :new, {curr_forum: forum.slug, year: '2012', mon: 'dec', day: '6', tid: 'obi-wan-kenobi', mid: message.message_id}
    end
  end

  test 'should not post do archived thread' do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    CfSetting.create!(forum_id: forum.forum_id, options: {'use_archive' => 'yes'})

    assert_raise CForum::ForbiddenException do
      post :create, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        cf_message: {
          subject: 'Long live the imperator!',
          author: 'Anaken Skywalker',
          content: 'Long live the imperator! Down with the rebellion!'
        }
      }
    end
  end

  test "should not vote because of anonymous" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)

    assert_raise CForum::ForbiddenException do
      post :vote, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s
      }
    end
  end

  test "should upvote" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    usr     = FactoryGirl.create(:cf_user)

    sign_in usr

    assert_difference 'CfVote.count' do
      post :vote, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        type: 'up'
      }
    end

    assert_redirected_to cf_message_url(thread, message)

    message.reload
    assert_equal 1, message.upvotes
  end

  test "should downvote" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    usr     = FactoryGirl.create(:cf_user)

    sign_in usr

    assert_difference 'CfVote.count' do
      post :vote, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        type: 'down'
      }
    end

    assert_redirected_to cf_message_url(thread, message)

    message.reload
    assert_equal 1, message.downvotes
  end

  test "should downchange vote" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, upvotes: 1)
    usr     = FactoryGirl.create(:cf_user)
    CfVote.create!(user_id: usr.user_id, message_id: message.message_id, vtype: CfVote::UPVOTE)

    sign_in usr

    assert_no_difference 'CfVote.count' do
      post :vote, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        type: 'down'
      }
    end

    assert_redirected_to cf_message_url(thread, message)

    message.reload
    assert_equal 0, message.upvotes
    assert_equal 1, message.downvotes
  end

  test "should upchange vote" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, downvotes: 1)
    usr     = FactoryGirl.create(:cf_user)
    CfVote.create!(user_id: usr.user_id, message_id: message.message_id, vtype: CfVote::DOWNVOTE)

    sign_in usr

    assert_no_difference 'CfVote.count' do
      post :vote, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        type: 'up'
      }
    end

    assert_redirected_to cf_message_url(thread, message)

    message.reload
    assert_equal 1, message.upvotes
    assert_equal 0, message.downvotes
  end


  test "vote up should score x points to bevoted user" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, downvotes: 1)
    usr     = FactoryGirl.create(:cf_user)

    sign_in usr

    assert_difference 'CfScore.count' do
      post :vote, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        type: 'up'
      }
    end

    s = CfScore.first
    assert_equal 10, s.value
  end

  test "vote down should score -x points to bevoted user and voter" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, downvotes: 1)
    usr     = FactoryGirl.create(:cf_user)

    sign_in usr

    assert_difference 'CfScore.count', 2 do
      post :vote, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        type: 'down'
      }
    end

    s = CfScore.find_by_user_id! usr.user_id
    assert_equal -1, s.value

    s = CfScore.find_by_user_id! message.user_id
    assert_equal -1, s.value
  end

  test "revote up should score x points to bevoted user and remove -score from voter" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, downvotes: 1)
    usr     = FactoryGirl.create(:cf_user)

    v = CfVote.create!(user_id: usr.user_id, message_id: message.message_id, vtype: CfVote::DOWNVOTE)
    CfScore.create!(user_id: usr.user_id, vote_id: v.vote_id, value: -1)
    CfScore.create!(user_id: message.user_id, vote_id: v.vote_id, value: -1)

    sign_in usr

    assert_difference 'CfScore.count', -1 do
      post :vote, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        type: 'up'
      }
    end

    s = CfScore.first
    assert_equal 10, s.value
  end


  test "should not upvote oneself" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    usr     = CfUser.find message.user_id

    sign_in usr

    assert_no_difference 'CfVote.count' do
      assert_no_difference 'CfScore.count' do
        post :vote, {
          curr_forum: forum.slug,
          year: '2012',
          mon: 'dec',
          day: '6',
          tid: 'obi-wan-kenobi',
          mid: message.message_id.to_s,
          type: 'up'
        }
      end
    end

    assert_redirected_to cf_message_url(thread, message)

    message.reload
    assert_equal 0, message.upvotes
  end

  test "should not downvote oneself" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    usr     = CfUser.find message.user_id

    sign_in usr

    assert_no_difference 'CfVote.count' do
      assert_no_difference 'CfScore.count' do
        post :vote, {
          curr_forum: forum.slug,
          year: '2012',
          mon: 'dec',
          day: '6',
          tid: 'obi-wan-kenobi',
          mid: message.message_id.to_s,
          type: 'down'
        }
      end
    end

    assert_redirected_to cf_message_url(thread, message)

    message.reload
    assert_equal 0, message.downvotes
  end

  test "should remove upvote" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, upvotes: 1)
    user    = FactoryGirl.create(:cf_user)
    vote    = CfVote.create!(message_id: message.message_id, user_id: user.user_id, vtype: CfVote::UPVOTE)
    score   = CfScore.create!(vote_id: vote.vote_id, user_id: message.user_id, value: 10)

    sign_in user

    assert_difference 'CfVote.count', -1 do
      assert_difference 'CfScore.count', -1 do
        post :vote, {
          curr_forum: forum.slug,
          year: '2012',
          mon: 'dec',
          day: '6',
          tid: 'obi-wan-kenobi',
          mid: message.message_id.to_s,
          type: 'up'
        }
      end
    end

    assert_redirected_to cf_message_url(thread, message)

    message.reload
    assert_equal 0, message.upvotes
  end

  test "should remove downvote" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, downvotes: 1)
    user    = FactoryGirl.create(:cf_user)
    vote    = CfVote.create!(message_id: message.message_id, user_id: user.user_id, vtype: CfVote::DOWNVOTE)
    score   = CfScore.create!(vote_id: vote.vote_id, user_id: message.user_id, value: -1)

    sign_in user

    assert_difference 'CfVote.count', -1 do
      assert_difference 'CfScore.count', -1 do
        post :vote, {
          curr_forum: forum.slug,
          year: '2012',
          mon: 'dec',
          day: '6',
          tid: 'obi-wan-kenobi',
          mid: message.message_id.to_s,
          type: 'down'
        }
      end
    end

    assert_redirected_to cf_message_url(thread, message)

    message.reload
    assert_equal 0, message.downvotes
  end

  test "should mark notification read and delete it when viewing message because of default" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, downvotes: 1)
    user    = FactoryGirl.create(:cf_user)

    CfNotification.create!(
      recipient_id: user.user_id,
      is_read: false,
      path: forum.slug + '/2012/dec/6/obi-wan-kenobi',
      subject: "You're my only hope!",
      icon: nil,
      oid: message.message_id,
      otype: 'message:create'
    )

    sign_in user

    assert_difference 'CfNotification.count', -1 do
      get :show, {
          curr_forum: forum.slug,
          year: '2012',
          mon: 'dec',
          day: '6',
          tid: 'obi-wan-kenobi',
          mid: message.message_id.to_s
        }
    end

    assert_response :success
    assert_not_nil assigns(:new_notifications)
    assert_empty assigns(:new_notifications)
  end

  test "should mark notification read but not delete it when viewing message because of config" do
    forum   = FactoryGirl.create(:cf_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, downvotes: 1)
    user    = FactoryGirl.create(:cf_user)

    CfSetting.create!(
      user_id: user.user_id,
      options: {'delete_read_notifications' => 'no'}
    )

    CfNotification.create!(
      recipient_id: user.user_id,
      is_read: false,
      path: forum.slug + '/2012/dec/6/obi-wan-kenobi',
      subject: "You're my only hope!",
      icon: nil,
      oid: message.message_id,
      otype: 'message:create'
    )

    sign_in user

    assert_no_difference 'CfNotification.count' do
      get :show, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s
      }
    end

    assert_response :success
    assert_not_nil assigns(:new_notifications)
    assert_empty assigns(:new_notifications)
  end


  test "nested-view should work too" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi', archived: true)
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, downvotes: 1)
    user    = FactoryGirl.create(:cf_user)

    CfSetting.create!(
      user_id: user.user_id,
      options: {'standard_view' => 'nested-view'}
    )

    sign_in user

    get :show, {
      curr_forum: forum.slug,
      year: '2012',
      mon: 'dec',
      day: '6',
      tid: 'obi-wan-kenobi',
      mid: message.message_id.to_s
    }
  end

  test "should not post when username is already taken" do
    forum = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)

    user = FactoryGirl.create(:cf_user)

    assert_no_difference 'CfMessage.count' do
      post :create, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        cf_message: {
          subject: 'Fighters of the world',
          author: user.username,
          content: 'Long live the imperator! Down with the rebellion!'
        }
      }
    end

    assert_response :success
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:thread)
  end

  test "should not post when too many tags are used" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    tag     = FactoryGirl.create(:cf_tag, forum: forum)
    CfSetting.create!(options: {'max_tags_per_message' => 1})

    user = FactoryGirl.create(:cf_user)
    sign_in user

    assert_no_difference 'CfMessage.count' do
      post :create, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        cf_message: {
          subject: 'Fighters of the world',
          content: 'Long live the imperator! Down with the rebellion!'
        },
        tags: [
          'tag1', 'tag2', 'tag3'
        ]
      }
    end

    assert_response :success
    assert_not_nil assigns(:message)
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:thread)
  end

  test "should post with not too many tags" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread)
    tag     = FactoryGirl.create(:cf_tag, forum: forum)
    CfSetting.create!(options: {'max_tags_per_message' => 4})

    user = FactoryGirl.create(:cf_user)
    sign_in user

    assert_difference 'CfMessage.count' do
      post :create, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        cf_message: {
          subject: 'Fighters of the world',
          content: 'Long live the imperator! Down with the rebellion!'
        },
        tags: [
          'tag1', 'tag2', 'tag3'
        ]
      }
    end

    assert_not_nil assigns(:message)
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:thread)

    assert_redirected_to cf_message_url(assigns(:thread), assigns(:message))
  end

  test "should not post answer deleted message" do
    forum   = FactoryGirl.create(:cf_write_forum)
    thread  = FactoryGirl.create(:cf_thread, forum: forum, slug: '/2012/dec/6/obi-wan-kenobi')
    message = FactoryGirl.create(:cf_message, forum: forum, thread: thread, deleted: true)

    assert_raise CForum::NotFoundException do
      post :create, {
        curr_forum: forum.slug,
        year: '2012',
        mon: 'dec',
        day: '6',
        tid: 'obi-wan-kenobi',
        mid: message.message_id.to_s,
        cf_message: {
          subject: 'Fighters of the world',
          content: 'Long live the imperator! Down with the rebellion!'
        }
      }
    end
  end

end

# eof
