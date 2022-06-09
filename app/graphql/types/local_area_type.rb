module Types
  class LocalAreaType < Types::BaseObject
    field :id, ID, null: false
    # field :path, String, null: false, method: :map_path
    # field :url, String, null: false, method: :map_url
    
    field :label, String, null: true
    field :latitude, Float, null: false
    field :longitude, Float, null: false
    field :time_zone, String, null: false
    
    field :province, String, null: true, method: :province_name
    field :country, String, null: true, method: :country_name
    field :province_code, String, null: true
    field :country_code, String, null: true

    field :events, [Types::EventType], null: false, resolver_method: :get_events

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def get_events
      object.events.publicly_visible.map { |event| event.extend(EventDecorator) }
    end
  end
end
