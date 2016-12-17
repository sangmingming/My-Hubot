module.exports = (robot) ->
	
	sendTodayGank = (msg) ->
		date = new Date()
		year = date.getFullYear()
		month = date.getMonth() + 1
		day = date.getDate() - 3
		url = "http://gank.io/api/day/#{year}/#{month}/#{day}"
		console.log(url)
		msg.http(url).get() (err, res, body) ->
			if res.statusCode isnt 200
				msg.send ":sob: 发生了错误，我不知道该怎么办了"
				return
			data = JSON.parse body
			if data.category.length == 0
				msg.send ":joy: 今天休息没干货"
				return
			datas = data.results
			title = "今日干货 #{year}年#{month}月#{day}日"
			arr = new Array()
			for key, contents of datas
				if key isnt "休息视频" and key isnt "福利"
					attachmentItem = {title:key, text:"", color: "#409fff"}
					for i,item of contents
						attachmentItem.text = attachmentItem.text + item.desc + "\n" + item.url + "     "
					arr.push attachmentItem
			msg.send title,arr
	
	sendItem = (msg, jsonResult) ->
		data = JSON.parse jsonResult
		if data.results.let == 0
			msg.send ":sob: 没有内容"
			return
		for item in data.results
			title = item.desc
			attachments = ""
			if item.type is "福利"
				attachments = [{text:"By: #{item.who} AT: #{item.publishedAt}", color:"#FF2741", images: [{url: item.url}]}]
			else
				attachments = [{title: item.type, text:item.url, color:"#8dd941"}]
			msg.send title, attachments	

	robot.hear /今日干货/i, (res) ->
		sendTodayGank res

	robot.hear /hi/i, (res) ->
		res.send "How are you?"
	
	robot.respond /open the pod bay doors/i, (res) ->
		res.reply "I'm afraid I can't let you do that."
	
	robot.hear /I like pie/i, (res) ->
		res.emote "make a freshly baked pie"

	robot.hear /妹子/i, (msg) ->
		msg.http("http://gank.io/api/random/data/%E7%A6%8F%E5%88%A9/1")
			.header("Accept", "application/json")
			.get() (err, res, body) ->
				sendItem msg, body
	robot.hear /find (.*) in (.*)/i, (msg) ->
		key = msg.match[1]
		category = msg.match[2]
		msg.http("http://gank.io/api/search/query/#{key}/category/#{category}/count/30/page/1").get() (err, res, body) ->
			sendItem msg, body
		
	robot.hear /random (.*)/i, (msg) ->
		key = msg.match[1]
		console.log(key)
		msg.http("http://gank.io/api/random/data/#{key}/1").get() (err, res, body) ->
			sendItem msg, body
