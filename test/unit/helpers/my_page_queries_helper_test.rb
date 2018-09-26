require File.expand_path('../../../test_helper', __FILE__)

class MyPageQueriesHelperTest < ActionView::TestCase
  fixtures :users, :user_preferences, :roles, :projects, :members, :member_roles,
           :issues, :issue_statuses, :trackers, :enumerations, :custom_fields,
           :auth_sources, :queries

  def test_extract_query_id_from_block
    block    = 'query_123'
    block_id = extract_query_id_from_block(block)
    assert_equal 123, block_id
  end

  def test_query_from_block
    user  = User.find(4)
    block = 'query_4'
    query = query_from_block(user, block)
    assert query
    assert_equal 4, query.id
  end

  def test_text_block
    assert text_block?('text_1')
    assert text_block?('text_12')
    refute text_block?('text_123n')
  end
end
