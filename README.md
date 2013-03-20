cm-kissmetrics
==============

Integrate CampaignMonitor and KISSMetrics! This gem will add historic information for your subscribers to KISSMetrics, including the date/time they initially subscribed, any emails they opened, links they clicked, and how long they stayed on your list.

Because KISSMetrics doesn't accept duplicate events, you can run this nightly in a cron job and KISSMetrics will ignore events that already exist, and create new events for things that haven't happened yet. In a future version only current events will be sent to KISSMetrics so the process is faster.

== Install Gems ==
* gem install km
* gem install createsend
* gem install cm-kissmetrics

== Set Up API Keys ==
* Create a file called keys.yaml in the directory you'll run cm-kissmetrics from. Add your API keys for KISSMetrics and CampaignMonitor, and the CampaignMonitor list ID you want to push historical information from. Here is an example:


km_key: xxxxxxx

cm_key: xxxxxxx

cm_list: xxxxxxx

== You're All Set ==
* Just type cm-kissmetrics

Depending on the size of your list and the number of emails you have sent, this could take a long time. You can monitor the progress of cm-kissmetrics by creating a folder called log in the directory you'll run cm-kissmetrics from. Once you have started cm-kissmetrics, you can tail log/kissmetrics_production_sent.log.
