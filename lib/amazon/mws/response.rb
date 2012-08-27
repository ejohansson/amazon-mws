module Amazon
  module MWS

    class Response < Node

      # This is the factoryish method that is called!, not new
      def self.format(response)
        if response.content_type =~ /xml/ || response.body =~ /<?xml/
          parse_xml(response)
        else
          response.body
        end
      end

      def self.parse_xml(response)
        if [Net::HTTPClientError, Net::HTTPServerError].any? {|error| response.is_a? error }
          return ResponseError.from_xml(response.body)
        else
          return self.from_xml(response.body)
        end
      end
    end

    # SHARED XML NODES SENT IN MULTIPLE RESPONSES

    class ReportSchedule < Node
      xml_name "ReportSchedule"

      xml_reader :report_type
      xml_reader :schedule
      xml_reader :scheduled_date, :as => Time
    end

    class ReportInfo < Node
      xml_name "ReportInfo"

      xml_reader :id, :from => "ReportId", :as => Integer
      xml_reader :type, :from => "ReportType"
      xml_reader :report_request_id, :as => Integer
      xml_reader :available_date, :as => Time
      xml_reader :acknowledged?
      xml_reader :acknowledged_date, :as => Time
    end

    class FeedSubmission < Node
      xml_name "FeedSubmissionInfo"

      xml_reader :id, :from => "FeedSubmissionId"
      xml_reader :feed_type
      xml_reader :submitted_date, :as => Time
      xml_reader :started_processing_date, :as => Time
      xml_reader :completed_processing_date, :as => Time      
      xml_reader :feed_processing_status
    end

    class ReportRequest < Node
      xml_name "ReportRequestInfo"

      xml_reader :id, :from => "ReportRequestId", :as => Integer
      xml_reader :report_id, :from => "GeneratedReportId", :as => Integer
      xml_reader :report_type
      xml_reader :start_date, :as => Time
      xml_reader :end_date, :as => Time
      xml_reader :scheduled?
      xml_reader :submitted_date, :as => Time
      xml_reader :report_processing_status
    end

  end
end
