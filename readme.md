# What?

Photo scraping script, written in Coffeescript, using Node

# Why?

Because recently I've had friends and family upload images to Smugmug and Zenfolio (or, more correctly, their photographers did so). Smugmug gives you some message when you try to right-click on an image to try to stop you from downloading it. Since I couldn't just grab the images I wanted, I wrote a script to grab them all.

It's hacky and incomplete, but I just downloaded over 1000 photos, so it does work. For now anyway. Also, the Zenfolio module doesn't currently work.

This probably won't be of use to anyone else, but I have no real reason not to share it.

# How?

You create a job file in the jobs folder in similar to the following, and include it in the `app.coffee` file:

    Site = require '../sites/smugmug'

    module.exports =
      url: "http://somealbum.smugmug.com/some/path"
      password: "password"
      site: Site
      imgs: ["http://site.com/path/to/image"]

Right now, it can't fetch images for you, so you have to rely on some Chrome/Firefox console action to fetch all the image names and populate that `imgs` array. This is due to Smugmug's use of YUI2 to load image data via Ajax after page load, and my lack of knowledge and unwillingness to learn how YUI2 works. Instead, I just did the following:

    jq = document.createElement('script'); jq.src="http://cdnjs.cloudflare.com/ajax/libs/jquery/1.8.3/jquery.min.js"; document.head.appendChild(jq);
    imgs = [];

    # repeat these over and over for each page
    $('#thumbnails').children('.photo').find('img').each(function(e,el){ imgs.push($(el).css('background-image')); })
    $('a.nav.next')[0].click();

    # copy the data to the clipboard
    copy(img);

Then I pasted that data into my text editor, did some find/replace and that was that.