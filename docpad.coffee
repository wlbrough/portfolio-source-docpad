# DocPad Configuration File
# http://docpad.org/docs/config

# Define the DocPad Configuration
docpadConfig = {
	templateData:
		site:
		  url: "https://www.billbroughton.me"
		  title: "Bill Broughton"
		  description: """
				My personal website for projects and writing.
			"""

		getPageTitle: -> if @document.title then "#{@document.title} | #{@site.title}" else @site.title;

	collections:
		pages: ->
			@getCollection("html").findAllLive({isPage: true});
		posts: ->
			@getCollection("html").findAllLive({relativeOutDirPath: 'posts'},[{date:-1}]);
		projects: ->
			@getCollection("html").findAllLive({relativeOutDirPath: 'projects'},[{date:-1}]);

	plugins:
		nodesass:
			options:
				includePaths: [__dirname + "/src/render/assets/scss"]
				outputStyle: 'compressed'
				debugInfo: 'map'
		ghpages:
      deployRemote: 'target'
      deployBranch: 'master'
}

# Export the DocPad Configuration
module.exports = docpadConfig
