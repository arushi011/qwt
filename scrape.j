const express = require('express');
const request = require("request");
const cheerio = require("cheerio");
const mongoose = require('mongoose');
mongoose.Promise = global.Promise;

var event = mongoose.model('events',{
  name : {
    type: String,
    required : true
  },
  desc : {
    type: String
  },
  firstStartedOn : {
    type: String
  },
  lastEditions : {
    type: String
  }, 
  startDate : {
    type: String,
    required : true
  },   
  endDate : {
    type: String
  },   
  address1 : {
    type: String,
    required : true
  },
  street : {
    type: String,
    required : true
  },
  city : {
    type: String,
    required : true
  },
  pinCode : {
    type: String,
    required : true
  },
  gMaps : {
    type: String
  },  
  genre : {
    type: String,
    required : true
  },
  link : {
    type: String
  },
  status : {
    type: String
  }
});
var eventList = [];
const app = express();
app.get('/home',(req,res)=>{
request({
  uri: "https://www.pw.org/calendar",
}, function(error, response, body) {
    if(error){
      console.log(error);
    }
    var $ = cheerio.load(body);
    var blocks = $("div.views-row > article");
    var headers = blocks.find("div.views-field-title>h2>a");
    var date = blocks.find("div.views-field-field-event-date>div>span.date-display-single");
    var genre = blocks.find("div.views-field-field-event-genre>span>span");
    var taxonomy = blocks.find("div.views-field-taxonomy-vocabulary-14>span>span");
    var address1 = blocks.find("div.views-field-field-event-location>div");
    var street = blocks.find("div.views-field-address>div>div>div>div.street-address>span");
    var city = blocks.find("div.views-field-address>div>div>div>span.locality");
    var postalCode = blocks.find("div.views-field-address>div>div>div>span.postal-code");

    for(i=0; i< blocks.length; i++)
    {
      var temp = new event({
        name: headers[i].children[0].data,
        startDate:date[i].children[0].data,
        endDate:date[i].children[0].data,
        address1:address1[i].children[0].data,
        street:street[i].children[0].data,
        city:city[i].children[0].data,
        pinCode:postalCode[i].children[0].data,
        genre:genre[i].children[0].data
      });
      eventList.push(temp);

    }
    mongoose.connect('mongodb://localhost:27017/personaDB').then(()=>{
      eventList.map((value)=>{value.save({})});
    }).then((event)=>{
      console.log(event)
    }).catch((e)=>{
    console.log(e);
    });
  });
});

const port = process.env.PORT || 5000;
app.listen(port, () => console.log(`Listening on port ${port}`));


