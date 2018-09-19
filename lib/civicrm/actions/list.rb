require 'json'

module CiviCrm
  module Actions
    module List
      module ClassMethods
        def all(params = {})
          params.merge!('entity' => entity_class_name, 'action' => 'get')
          params = handle_pagination(params)
          response = CiviCrm::Client.request(:get, params)
          Resource.build_from(response, params)
        end
        alias find_by all

        def count(params = {})
          params.merge!('entity' => entity_class_name, 'action' => 'getCount')
          response = CiviCrm::Client.request(:get, params)
          count = response.first&.dig('result')&.to_i
          count = false if count.nil?
          count
        end
        alias total count

        def pages(params = {})
          the_count = count(params)
          page_count = (the_count / CiviCrm.per_page).ceil
          page_count
        end

        def find_first_by(params={})
          all(params).first
        end

        def first(params = {})
          all(params).first
        end

        def last(params = {})
          all(params).last
        end

        def handle_pagination(params = {})
          if params.key?(:page) || params.key?('page')
            page_number = params.dig(:page) || params.dig('page')
            offset = (page_number - 1) * CiviCrm.per_page
            params['options'] = {
              limit:  CiviCrm.per_page,
              offset: offset
            }
            params.except(:page, 'page')
          end
          params
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
