package controllers

import (
	"log"
	"os"

	"github.com/mrjones/oauth"
	"github.com/revel/revel"
)

var TWITTER = oauth.NewConsumer(
	os.Getenv("CONSUMER_KEY"),
	os.Getenv("CONSUMER_SECRET"),
	oauth.ServiceProvider{
		AuthorizeTokenUrl: "https://api.twitter.com/oauth/authorize",
		RequestTokenUrl:   "https://api.twitter.com/oauth/request_token",
		AccessTokenUrl:    "https://api.twitter.com/oauth/access_token",
	},
)

type Session struct {
	*revel.Controller
}

func (c Session) New() revel.Result {
	_, callbackUrl, err := TWITTER.GetRequestTokenAndUrl("http://127.0.0.1:9000/auth/twitter/callback")
	if err != nil {
		log.Fatal(err)
	}

	return c.Redirect(callbackUrl)
}

func (c Session) Create() revel.Result {
	return c.Render()
}
