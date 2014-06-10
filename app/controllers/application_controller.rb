class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  filter_access_to :all

  helper_method :prismic_api, :prismic_ref, :prismic_link_resolver

  # Prismic Stuff
  def prismic_api
    @prismic ||= Prismic.api(ENV['PRISMIC_URL'])
  end

  # Return the actual used reference
  def prismic_ref
    @ref ||= prismic_api.master_ref.ref
  end

  # Return the set reference
  def prismic_maybe_ref
    nil
  end

  def prismic_link_resolver(maybe_ref = nil)
    @link_resolver ||= Prismic::LinkResolver.new(maybe_ref) do |doc|
      root_path
      # document_path(id: doc.id, slug: doc.slug, ref: maybe_ref)
      # maybe_ref is not expected by document path, so it appends a ?ref=maybe_ref to the URL;
      # since maybe_ref is nil when on master ref, it appends nothing.
      # You should do the same for every path method used here in the link_resolver and elsewhere in your app,
      # so links propagate the ref id when you're previewing future content releases.
    end
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end
