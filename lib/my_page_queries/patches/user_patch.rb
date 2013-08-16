require 'principal'
require 'user'

module MyPageQueries::Patches::UserPatch
  extend ActiveSupport::Concern

  def detect_query(query_id)
    visible_queries.detect { |q| q.id == query_id.to_i }
  end

  def visible_queries
    @visible_queries ||= my_visible_queries.to_a + other_visible_queries.to_a
  end

  def my_visible_queries
    visible_queries_scope.where('queries.user_id = ?', self.id).order('queries.name')
  end

  def other_visible_queries
    visible_queries_scope.where('queries.user_id <> ?', self.id).order('queries.name')
  end

  def visible_queries_scope
    kl = defined?(IssueQuery) ? IssueQuery : Query
    kl.visible(self)
  end
end

unless User.included_modules.include?(MyPageQueries::Patches::UserPatch)
  User.send :include, MyPageQueries::Patches::UserPatch
end
