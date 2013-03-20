require "cm-kissmetrics/version"

module CmKissmetrics
    
    require 'createsend'
    require 'km'
    require 'date'

    def self.initialize(km_key, cm_key, cm_list, allowed_history_days = 0)
        @km_key = km_key
        @cm_key = cm_key
        @cm_list = cm_list
        @allowed_history_days = allowed_history_days
        @now = DateTime.now.to_time.to_i

        KM.init(@km_key, :log_dir => 'log/')
        CreateSend.api_key @cm_key

        @list = CreateSend::List.new @cm_list

        ['active','unsubscribed','bounced','deleted'].each{|s|
            res = eval("@list.#{s.downcase} '1970-01-01'")
            res.Results.each{|p|
                CmKissmetrics::record(p, s)
            }
        }
    end

    def self.record(p, type)
        email = p.EmailAddress

        begin
            KM.identify(email)

            details = CreateSend::Subscriber.get @cm_list, email
            ts = DateTime.parse(details.Date).to_time.to_i
            
            if @now - ts <= (@allowed_history_days * 86400) || @allowed_history_days == 0
                case type
                    when 'active' then label = 'Subscribed to Email'
                    when 'unsubscribed' then label = 'Unsubscribed from Email'
                    when 'bounced' then label = 'Bounced from Email'
                    when 'deleted' then label = 'Deleted from Email'
                end
                
                KM.record(label, {'List' => @list.details.Title, '_d' => 1, '_t' => ts})
                details.CustomFields.each{|field|
                    if ['City','Province','Postal Code','Source'].include? field.Key
                        KM.set({field.Key => field.Value}) if field.Value != '' && field.Value != nil
                    end
                }

                person = CreateSend::Subscriber.new @cm_list, email
                history = person.history
                history.each{|h|
                    h.Actions.each{|a|
                        ts = DateTime.parse(a.Date).to_time.to_i
                        if a.Event == 'Open'
                            KM.record('Opened Email', {'Email' => h.Name, '_d' => 1, '_t' => ts})
                        elsif a.Event == 'Click'
                            KM.record('Clicked from Email', {'Email' => h.Name, 'Link' => a.Detail, '_d' => 1, '_t' => ts})
                        end
                    }
                }
            end
        rescue StandardError => e
            puts e.message
        end
    end
end
