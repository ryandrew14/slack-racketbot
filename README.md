# Racket Helper

Racket Helper is a Slack app to run the racket code that is passed to it as a "slash command".

Be careful running this on a server you care about - it's currently a glorified `eval`.

# Adding the app to your slack server

<a href="https://slack.com/oauth/authorize?scope=commands,bot&client_id=437530082994.436948745745"><img alt="Add to Slack" height="40" width="139" src="https://platform.slack-edge.com/img/add_to_slack.png" srcset="https://platform.slack-edge.com/img/add_to_slack.png 1x, https://platform.slack-edge.com/img/add_to_slack@2x.png 2x" /></a>

# Using the app

Just use `/racket <code here>` in any channel you've given the bot access to.
