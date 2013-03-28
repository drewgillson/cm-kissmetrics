cm-kissmetrics
==============

Integrate CampaignMonitor and KISSMetrics! This gem will add historic information for your subscribers to KISSMetrics, including the date/time they initially subscribed, any emails they opened, links they clicked, and how long they stayed on your list.

Because KISSMetrics doesn't accept duplicate events, you can run this nightly in a cron job and KISSMetrics will ignore events that already exist, and create new events for things that haven't happened yet. In a future version only current events will be sent to KISSMetrics so the process is faster.

Just clone the repository and do a bundle install.

Then, set up your API keys:
* Create a file called config.yaml in the directory you'll run cm-kissmetrics from. Add your API keys for KISSMetrics and CampaignMonitor, and the CampaignMonitor list ID you want to push historical information from. Here is an example:

    km_key: xxxxxxx<br/>
    cm_key: xxxxxxx<br/>
    cm_list: xxxxxxx<br/>

You can also add the parameter allowed_history_days, to specify the maximum age in days for events pushed to KISSMetrics. For instance, if you set this parameter to 1, only email events that have been opened and clicked within the last 24 hours will be sent to KISSMetrics.

You're All Set
Add a regular cron task to run cm-kissmetrics!

Depending on the size of your list and the number of emails you have sent, this could take a long time. You can monitor the progress of cm-kissmetrics by creating a folder called log in the directory you'll run cm-kissmetrics from. Once you have started cm-kissmetrics, you can tail log/kissmetrics_production_sent.log.
