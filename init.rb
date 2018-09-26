require 'redmine'

ActionDispatch::Callbacks.to_prepare do
  require 'my_page_queries'
end

Redmine::Plugin.register :redmine_my_page_queries do
  name 'MyPage custom queries for Redmine 3.4.x'
  description 'Adds custom queries onto My Page screen for Redmine 3.4.x'
  version '2.2.0'
  author 'Nagasawa'
  author_url 'https://github.com/minoru-nagasawa/'
  url 'https://github.com/minoru-nagasawa/redmine_my_page_queries'
end
