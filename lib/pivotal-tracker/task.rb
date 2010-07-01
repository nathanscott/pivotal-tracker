module PivotalTracker
  class Task
    include HappyMapper

    attr_accessor :project_id, :story_id

    class << self
      def all(story, options={})
        puts "/projects/#{story.project_id}/stories/#{story.id}/tasks"
        tasks = parse(Client.connection["/projects/#{story.project_id}/stories/#{story.id}/tasks"].get)
        tasks.each { |t| t.project_id, t.story_id = story.project_id, story.id }
        return tasks
      end
    end

    element :id, Integer
    element :description, String
    element :position, Integer
    element :complete, Boolean
    element :created_at, DateTime

    def create
      response = Client.connection["/projects/#{project_id}/stories/#{story_id}/tasks"].post(self.to_xml, :content_type => 'application/xml')
      return Task.parse(response)
    end

    def update
      response = Client.connection["/projects/#{project_id}/stories/#{story_id}/tasks/#{id}"].put(self.to_xml, :content_type => 'application/xml')
      return Task.parse(response)
    end

    def delete
      Client.connection["/projects/#{project_id}/stories/#{story_id}/tasks/#{id}"].delete
    end

    protected

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.task {
            xml.description "#{description}"
            # xml.position "#{position}"
            xml.complete "#{complete}"
          }
        end
      end

  end
end
