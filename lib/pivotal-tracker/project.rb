module PivotalTracker
  class Project
    include HappyMapper

    class << self
      def all
        @found = parse(Client.connection['/projects'].get)
      end

      def find(id)
        if @found
          @found.detect { |document| document.id == id }
        else
          parse(Client.connection["/projects/#{id}"].get)
        end
      end
    end

    element :id, Integer
    element :name, String
    element :week_start_day, String
    element :point_scale, String
    element :week_start_day, String
    element :velocity_scheme, String
    element :iteration_length, Integer
    element :initial_velocity, Integer
    element :current_velocity, Integer
    element :last_activity_at, DateTime
    
    
    def create
      response = Client.connection["/projects"].post(self.to_xml, :content_type => 'application/xml')
      return Project.parse(response)
    end

    def update(attrs={})
      update_attributes(attrs)
      response = Client.connection["/projects/#{id}"].put(self.to_xml, :content_type => 'application/xml')
      return Project.parse(response)
    end

    def delete
      Client.connection["/projects/#{id}"].delete
    end

    def activities
      @activities ||= Proxy.new(self, Activity)
    end

    def iterations
      @iterations ||= Proxy.new(self, Iteration)
    end

    def stories
      @stories ||= Proxy.new(self, Story)
    end

    def memberships
      @memberships ||= Proxy.new(self, Membership)
    end

    protected

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.project {
            xml.name "#{name}"
            # xml.description "#{description}"
            # xml.story_type "#{story_type}"
            # xml.estimate "#{estimate}"
            # xml.current_state "#{current_state}"
            # xml.requested_by "#{requested_by}"
            # xml.owned_by "#{owned_by}"
            # xml.labels "#{labels}"
            # # See spec
            # # xml.jira_id "#{jira_id}"
            # # xml.jira_url "#{jira_url}"
            # xml.other_id "#{other_id}"
          }
        end
        return builder.to_xml
      end

      def update_attributes(attrs)
        attrs.each do |key, value|
          self.send("#{key}=", value.is_a?(Array) ? value.join(',') : value )
        end
      end

  end
end
