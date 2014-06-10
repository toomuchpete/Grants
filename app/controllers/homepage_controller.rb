class HomepageController < ApplicationController
  def index
    # Pull prismic articles
    prismic = Prismic.api(ENV['PRISMIC_URL'])
    @link_resolver = Prismic::LinkResolver.new(nil){|doc| root_path}
    @documents = prismic.form('homepage').submit(prismic.master_ref.ref)
  end
end
