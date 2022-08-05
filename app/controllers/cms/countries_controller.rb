class CMS::CountriesController < CMS::ApplicationController

  prepend_before_action { @model = Country }

  def create
    super parameters
  end

  def update
    super parameters
  end

  private

    def parameters
      params.fetch(:country, {}).permit(:country_code, :default_language_code, :enable_region_management, :bounds)
    end

end
