module.exports = (robot) ->
	
	sendTodayGank = (msg) ->
		date = new Date()
		year = date.getFullYear()
		month = date.getMonth() + 1
		day = date.getDate()
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
					itemString = "**" +key + "**    "
					for i,item of contents
						itemString = itemString + item.desc + " " + item.url + "     "
					arr.push itemString
					console.log(itemString)
			attachments = [{text:arr.join("    "), color:"#409fff"}]
			msg.send title,attachments

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
				data = JSON.parse body
				title = data.results[0].desc
				attachments = [{
					title: "妹子图",
					color: "#FF2741",
					images: [{url: data.results[0].url}]
				}]
				msg.send title,attachments
				return
	robot.hear /find (.*) in (.*)/i, (msg) ->
		key = msg.match[1]
		category = msg.match[2]
		msg.http("http://gank.io/api/search/query/#{key}/category/#{category}/count/30/page/1").get() (err, res, body) ->
			data = JSON.parse body
			for item in data.results
				title = item.desc
				attachments = [{title: item.desc, text:"By: #{item.who} AT: #{item.publishedAt}", color:"#8dd941"}]
				msg.send "#{item.url}",attachments
		
	robot.hear /random (.*)/i, (msg) ->
		key = msg.match[1]
		console.log(key)
		msg.http("http://gank.io/api/random/data/#{key}/1").get() (err, res, body) ->
			data = JSON.parse body
			title = data.results[0].desc
			link = data.results[0].url
			msg.send "[#{title}](#{link})"	
