require File.dirname(__FILE__) + '/../test_helper'

class CustomMessageSettingsControllerTest < Redmine::ControllerTest
  fixtures :custom_message_settings
  include Redmine::I18n

  def setup
    @request.session[:user_id] = 1 # admin
    CustomMessageSetting.reload_translations!('en')
    I18n.load_path = (I18n.load_path + Dir.glob(Rails.root.join('plugins', 'redmine_message_customize', 'config', 'locales', 'custom_messages', '*.rb'))).uniq
  end

  # custom_message_settings/edit
  def test_edit
    get :edit
    assert_response :success

    assert_select 'h2', :text => l(:label_custom_messages)
    assert_select 'div.tabs' do
      assert_select 'a#tab-normal'
      assert_select 'a#tab-yaml'
    end
  end
  def test_edit_except_admin_user
    @request.session[:user_id] = 2
    get :edit
    assert_redirected_to (/#{signin_path}/)
  end

  def test_update_with_custom_messages
    assert_equal 'Home1', l(:label_home)

    get :update, params: { settings: {'custom_messages'=>{'label_home' => 'Home3'}}, lang: 'en', tab: 'normal' }

    assert_equal 'Home3', l(:label_home)
    assert_redirected_to edit_custom_message_settings_path(lang: 'en', tab: 'normal')
    assert_equal l(:notice_successful_update), flash[:notice]
  end
  def test_update_with_custom_messages_yaml
    assert_equal 'Home1', l(:label_home)

    get :update, params: { settings: {'custom_messages_yaml'=>"---\nen:\n  label_home: Home3"}, tab: 'yaml' }

    assert_equal 'Home3', l(:label_home)
    assert_redirected_to edit_custom_message_settings_path(lang: 'en', tab: 'yaml')
    assert_equal l(:notice_successful_update), flash[:notice]
  end
  def test_update_with_invalid_params
    get :update, params: { settings: {'custom_messages'=>{'foobar'=>'foobar'}, lang: 'en' }}

    assert_response 200
    assert_select 'h2', :text => l(:label_custom_messages)
    assert_select 'div#errorExplanation'
  end
  def test_update_except_admin_user
    @request.session[:user_id] = 2
    get :update, params: { settings: {'custom_messages'=>{'label_home' => 'Home3'}}, lang: 'en', tab: 'normal' }

    assert_redirected_to (/#{signin_path}/)
  end

  def test_toggle_enabled
    patch :toggle_enabled
    assert_redirected_to edit_custom_message_settings_path
    assert_equal l(:notice_disabled_customize), flash[:notice]

    patch :toggle_enabled
    assert_equal l(:notice_enabled_customize), flash[:notice]
  end
  def test_toggle_enabled_except_admin_user
    @request.session[:user_id] = 2
    patch :toggle_enabled

    assert_redirected_to (/#{signin_path}/)
  end
end
