/**
 * This system defines news that will be displayed in the course of a round.
 * Uses BYOND's type system to put everything into a nice format.
 */
/datum/news_announcement

	/// Time of the round at which this should be announced, in seconds.
	var/round_time
	/// Body of the message.
	var/message
	var/author = "Unknown Editor"
	var/can_be_redacted = 0
	var/message_type = "Story"
	var/channel_name = null

/datum/news_announcement/New() // I'm sorry...
	..()
	channel_name = "The [GLOB.using_map.starsys_name] Times"

// This is now a blank slate for periodic news Tag - ADDFLAVOR

/proc/process_newscaster()
	check_for_newscaster_updates(SSticker.mode.newscaster_announcements)

/var/global/tmp/announced_news_types = list()
/proc/check_for_newscaster_updates(type)
	for(var/subtype in typesof(type)-type)
		var/datum/news_announcement/news = new subtype()
		if(news.round_time * 10 <= world.time && !(subtype in announced_news_types))
			announced_news_types += subtype
			announce_newscaster_news(news)

/proc/announce_newscaster_news(datum/news_announcement/news)
	var/datum/feed_channel/sendto
	for(var/datum/feed_channel/FC in news_network.network_channels)
		if(FC.channel_name == news.channel_name)
			sendto = FC
			break

	if(!sendto)
		sendto = new /datum/feed_channel
		sendto.channel_name = news.channel_name
		sendto.author = news.author
		sendto.locked = 1
		sendto.is_admin_channel = 1
		news_network.network_channels += sendto

	var/author = news.author ? news.author : sendto.author
	news_network.SubmitArticle(news.message, author, news.channel_name, null, !news.can_be_redacted, news.message_type)
