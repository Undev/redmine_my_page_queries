require File.expand_path('../../../test_helper', __FILE__)
require 'my_controller'

# Re-raise errors caught by the controller.
class MyController;
  def rescue_action(e)
    raise e
  end

  ;
end

class MyPageQueries::MyControllerTest < ActionController::TestCase
  fixtures :users, :user_preferences, :roles, :projects, :members, :member_roles,
           :issues, :issue_statuses, :trackers, :enumerations, :custom_fields, :auth_sources,
           :queries, :trackers, :enabled_modules

  def setup
    @controller                = MyController.new
    @request                   = ActionController::TestRequest.new
    @request.session[:user_id] = 2
    @response                  = ActionController::TestResponse.new
    @user                      = User.find(2)
  end

  def test_index
    get :index
    assert_response :success
  end

  def test_page_layout_with_query_block
    query                       = Query.find(5)
    @user.pref[:my_page_layout] = { 'top' => ['query_5'] }
    @user.pref.save!
    get :page
    assert_response :success
    assert_select 'h3', html: /#{query.name}/
  end

  def test_page_layout_with_text_block
    @user.update_my_page_text_block('text_1', 'some-text-1')
    @user.pref[:my_page_layout] = { 'top' => ['text_1'] }
    @user.pref.save!
    get :page
    assert_response :success
    assert_select 'div', html: /some-text-1/
  end

  def test_page_layout_with_already_added_query
    query                       = Query.find(5)
    @user.pref[:my_page_layout] = { 'top' => ['query_5'] }
    @user.pref.save!
    get :page
    assert_response :success
    assert_select 'option', { html: /#{query.name}/, count: 0 }
  end

  def test_textblock_available_even_with_already_added_block
    @user.update_my_page_text_block('text_1', 'sometext1')
    @user.pref[:my_page_layout] = { 'top' => ['text_1'] }
    @user.pref.save!
    get :page
    assert_response :success
    assert_select 'option[value="text_2"]', true
  end

  def test_page_layout_with_missing_query
    @user.pref[:my_page_layout] = { 'top' => ['query_66'] }
    @user.pref.save!
    get :page
    assert_response :success
  end

  def test_page_layout_with_missing_text
    @user.pref[:my_page_layout] = { 'top' => ['text_66'] }
    @user.pref.save!
    get :page
    assert_response :success
  end

  def test_add_query_block
    post :add_block, block: 'query_5'
    assert_redirected_to '/my/page'
    assert @user.pref[:my_page_layout]
    top_blocks = @user.pref[:my_page_layout]['top']
    assert top_blocks
    assert top_blocks.include?('query_5')
  end

  def test_add_text_block
    post :add_block, block: 'text_1'
    assert_redirected_to '/my/page'
    xhr :put, :update_text_block, block_name: 'text_1', my_page_text_area: 'sample message'
    @user.pref.reload
    assert @user.pref[:my_page_layout]
    top_blocks  = @user.pref[:my_page_layout]['top']
    text_blocks = @user.pref[:my_page_text_blocks]
    assert top_blocks
    assert top_blocks.include?('text_1')
    assert text_blocks
    assert text_blocks.keys.include?('text_1')
    assert_equal 'sample message', text_blocks['text_1']
  end

  def test_add_second_text_block
    @user.update_my_page_text_block('text_1', 'some-text-1')
    @user.pref[:my_page_layout] = { 'top' => ['text_1'] }
    @user.pref.save!
    post :add_block, block: 'text_2'
    assert_redirected_to '/my/page'
    @user.pref.reload
    assert @user.pref[:my_page_layout]
    top_blocks = @user.pref[:my_page_layout]['top']
    assert top_blocks
    assert top_blocks.include?('text_2')
  end

  def test_add_first_text_block
    @user.update_my_page_text_block('text_1', 'some-text-1')
    @user.update_my_page_text_block('text_2', 'some-text-2')
    @user.pref[:my_page_layout] = { 'top' => ['text_2'] }
    @user.pref.save!
    post :add_block, block: 'text_1'
    assert_redirected_to '/my/page'
    @user.pref.reload
    assert @user.pref[:my_page_layout]
    top_blocks = @user.pref[:my_page_layout]['top']
    assert top_blocks
    assert top_blocks.include?('text_1')
  end

  def test_show_query_block
    query                       = Query.find(5)
    @user.pref[:my_page_layout] = { 'top' => ['query_5'] }
    @user.pref.save!
    get :page
    assert_response :success
    assert_select 'h3', html: /#{query.name}/
  end

  def test_show_text_block
    @user.update_my_page_text_block('text_1', 'some-show-text-1')
    @user.pref[:my_page_layout] = { 'top' => ['text_1'] }
    @user.pref.save!
    get :page
    assert_response :success
    assert_select 'div', html: /some-show-text-1/
  end

  def test_add_query_block_to_default
    @user.pref[:my_page_layout] = nil
    post :add_block, block: 'query_5'
    assert_redirected_to '/my/page'
    @user = User.current
    Redmine::MyPage.default_layout.each do |position, block|
      assert @user.pref[:my_page_layout][position].include?(block.first)
    end
  end

  def test_add_text_block_to_default
    @user.pref[:my_page_layout]      = nil
    @user.pref[:my_page_text_blocks] = nil
    @user.pref.save!
    post :add_block, block: 'text_1'
    assert_redirected_to '/my/page'
    xhr :put, :update_text_block, block_name: 'text_1', my_page_text_area: 'sample message'
    @user = User.current
    Redmine::MyPage.default_layout.each do |position, block|
      assert @user.pref[:my_page_layout][position].include?(block.first)
    end
    top_blocks  = @user.pref[:my_page_layout]['top']
    text_blocks = @user.pref[:my_page_text_blocks]
    assert top_blocks
    assert top_blocks.include?('text_1')
    assert text_blocks
    assert text_blocks.keys.include?('text_1')
    assert_equal 'sample message', text_blocks['text_1']
  end

  def test_remove_query_block
    @user.pref[:my_page_layout] = { 'top' => ['query_5'] }
    @user.pref.save!
    post :remove_block, block: 'query_5'
    assert_redirected_to '/my/page'
    @user.pref.reload
    refute @user.pref[:my_page_layout].values.flatten.include?('query_5')
  end

  def test_remove_text_block
    @user.update_my_page_text_block('text_1', 'some-show-text-1')
    @user.pref[:my_page_layout] = { 'top' => ['text_1'] }
    @user.pref.save!
    post :remove_block, block: 'text_1'
    assert_redirected_to '/my/page'
    @user.pref.reload
    refute @user.pref[:my_page_layout].values.flatten.include?('text_1')
    assert_equal 'some-show-text-1', @user.my_page_text_block('text_1'), 'Text content should stay persisted'
  end

  def test_order_blocks
    @user.pref[:my_page_layout] = { 'left' => ['latestnews', 'query_5', 'calendar'] }
    @user.pref.save!
    xhr :post, :order_blocks, group: 'left', 'blocks' => ['query_5', 'calendar', 'latestnews']
    assert_response :success
    @user.pref.reload
    assert_equal ['query_5', 'calendar', 'latestnews'], @user.pref[:my_page_layout]['left']
  end

  def test_layout_contains_users_queries
    get :page
    assert_response :success
    assert_select 'option[value="query_4"]', true
  end

  def test_layout_contains_other_queries
    get :page
    assert_response :success
    assert_select 'option[value="query_5"]', true
    assert_select 'option[value="query_6"]', true
    assert_select 'option[value="query_9"]', true
  end

  def test_update_query_limit
    @user.pref[:my_page_layout] = { 'top' => ['query_5'] }
    @user.pref[:query_5]        = { limit: 20 }
    @user.pref.save!
    xhr :put, :update_query_block, query_id: 5, query: { limit: 3 }
    assert_response :success
    @user.pref.reload
    assert_equal 3, @user.pref[:query_5][:limit].to_i
  end

end
