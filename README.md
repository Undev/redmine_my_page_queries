# Redmine My Page Queries

[![Build Status](https://travis-ci.org/minoru-nagasawa/redmine_my_page_queries.svg?branch=master)](https://travis-ci.org/minoru-nagasawa/redmine_my_page_queries)
[![Code Climate](https://codeclimate.com/github/minoru-nagasawa/redmine_my_page_queries.png)](https://codeclimate.com/github/minoru-nagasawa/redmine_my_page_queries)

This plugin enhances **My page** screen in Redmine with the following blocks:

* **My custom queries** block
* Separate blocks for each query with either compact or extended view
* **Text** block to add custom text

The initial author is [ALVILA](https://github.com/alvila/redmine_my_page_queries).

## Compatibility

This plugin version is compatible with Redmine 3.4.x.  
Before version 3.3 is here. (https://github.com/Restream/redmine_my_page_queries)

## Installation


1. To install the plugin
    * Download the .ZIP archive, extract files and copy the plugin directory into #{REDMINE_ROOT}/plugins.
    
    Or

    * Change you current directory to your Redmine root directory:  

            cd {REDMINE_ROOT}
            
      Copy the plugin from GitHub using the following commands:
      
            git clone https://github.com/Restream/redmine_my_page_queries.git plugins/redmine_my_page_queries           
      
2. Update the Gemfile.lock file by running the following commands:  

         rm Gemfile.lock  
         bundle install 

3. Restart Redmine.

Now you should be able to see the plugin in **Administration > Plugins**.

If you are upgrading Redmine from previous versions (prior to 2.0.0) and you want to save user settings related to custom queries on the **My page** screen, run the following command:

        rake my_page_queries:upgrade RAILS_ENV=production

## Usage

This plugin enhances the **My page** screen with several useful blocks related to user's custom queries. 

To add a block that displays all your queries, click **Personalize this page**, select **My custom queries** in the drop-down list and then click **Add**.  
![custom queries](doc/my_page_queries_1.png)

To add a block with issues that match a particular query, select this query name in the **My custom queries** section of the drop-down list, and click **Add**.

The **Queries from my projects** section in the drop-down list contains all public filters created by other users based on your projects. The **Queries from public projects** section shows other public filters from public projects.

You can switch between a compact and extended view by clicking the corresponding links.  
![compact and extended view](doc/my_page_queries_2.png)

## Maintainers

Danil Tashkinov, [github.com/nodecarter](https://github.com/nodecarter)
