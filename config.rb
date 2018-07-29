###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
page "/documentation/1.x/*", :layout => '1.x.erb'
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# activate :livereload

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

# middleman-syntax
activate :syntax
set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true, autolink: true, with_toc_data: true
I18n.enforce_available_locales = false

set :latest_scala_version, "2.12.6"

# Latest Skinny Framework version
@skinny1_version = "1.3.20"
set :skinny1_version, @skinny1_version
@skinny1_blank_app_version = @skinny1_version
set :skinny1_blank_app_version, @skinny1_blank_app_version

set :skinny_micro_version, "2.0.0"
@skinny_version = "3.0.0"
set :skinny_version, @skinny_version
@skinny_blank_app_version = @skinny_version
set :skinny_blank_app_version, @skinny_blank_app_version

@scalikejdbc_version = "3.3.0"
set :scalikejdbc_version, @scalikejdbc_version

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

activate :deploy do |deploy|
  deploy.build_before = true
  deploy.method = :git
  deploy.branch = 'master'
end
