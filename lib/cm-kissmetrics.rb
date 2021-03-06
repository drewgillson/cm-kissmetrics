require "net/http"
require "cgi"
require "cm-kissmetrics/version"
require "cm-kissmetrics/km"

module CmKissmetrics
    
    require 'createsend'
    require 'date'

    def self.initialize(km_key, cm_key, cm_list, page_size, current_page, allowed_history_days = 0)
        @km_key = km_key
        @cm_key = cm_key
        @cm_list = cm_list
        @allowed_history_days = allowed_history_days
        @now = DateTime.now.to_time.to_i
        @auth = {:api_key => @cm_key}
        cs = CreateSend::CreateSend.new @auth

        @list = CreateSend::List.new @auth, @cm_list

        ['active','unsubscribed','bounced','deleted'].each{|s|
            res = eval("@list.#{s.downcase} '1970-01-01', #{current_page}, #{page_size}")
            until res.Results.count == 0
                puts "#{s.to_s} list, page #{current_page}: #{res.Results.count.to_s} records"
                current_page = current_page + 1
                subscribers = []
                res = eval("@list.#{s.downcase} '1970-01-01', #{current_page.to_s}, #{page_size}")
                res.Results.each{|p|
                    d = {'p' => p, 's' => s}
                    subscribers << Thread.new(d){|d| CmKissmetrics::record(d)}               
                }
                subscribers.each { |t| t.join }
                subscribers.each { |t| t.exit }
                puts "Finished processing #{page_size} subscribers"
            end
            current_page = 1
        }
    end

    def self.record(d)
        p = d['p']
        type = d['s']
        email = p.EmailAddress

        begin
            k = KM.new
            k.init(@km_key, :log_dir => 'log/')
            k.identify(email)

            details = CreateSend::Subscriber.get @auth, @cm_list, email
            ts = DateTime.parse(details.Date).to_time.to_i
            
            case type
                when 'active' then label = 'CM subscribed to email'
                when 'unsubscribed' then label = 'CM unsubscribed from email'
                when 'bounced' then label = 'CM bounced from email'
                when 'deleted' then label = 'CM deleted from email'
            end
            
            k.record(label, {'List' => @list.details.Title, '_d' => 1, '_t' => ts})
            details.CustomFields.each{|field|
                if ['City','Province','Postal Code','Source'].include? field.Key
                    k.set({field.Key => field.Value}) if field.Value != '' && field.Value != nil
                end
            }

            subscriber_events = []
            person = CreateSend::Subscriber.new @auth, @cm_list, email
            history = person.history
            history.each{|h|
                h.Actions.each{|a|
                    ts = DateTime.parse(a.Date).to_time.to_i
                    if @now - ts <= (@allowed_history_days * 86400) || @allowed_history_days == 0
                        if a.Event == 'Open'
                            data = {'Email' => h.Name, '_d' => 1, '_t' => ts}
                            subscriber_events << Thread.new(data){|data| k.record('CM opened an email', data)}
                        elsif a.Event == 'Click'
                            data = {'Email' => h.Name, 'Link' => a.Detail, '_d' => 1, '_t' => ts}
                            subscriber_events << Thread.new(data){|data| k.record('CM clicked something in an email', data)}
                        end
                    end
                }
            }
            subscriber_events.each { |t| t.join }
            subscriber_events.each { |t| t.exit }
            person = nil
            history = nil
            details = nil
            puts "Finished recording events for #{email}"
        rescue StandardError => e
            puts e.message
        end
    end
end
