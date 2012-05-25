#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import webapp2
import json

import photos
import mapannotations

class MainHandler(webapp2.RequestHandler):
    def get(self):
        self.response.out.write('Hello world!')

class Play2BannerHandler(webapp2.RequestHandler):
	def get(self):
		# returns an array of image urls for the Play2 banner view
		banners = [
			"http://play2server.appspot.com/static/banners/play2_banner_420px.png",
			"http://play2server.appspot.com/static/banners/banner_placeholder.png"
		]

		self.response.headers['Content-Type'] = 'application/json'
		self.response.headers['Cache-Control'] = 'public, max-age=1200'
		self.response.out.write(json.dumps(banners, indent=4))

routes = [
	('/', MainHandler),
	('/banners', Play2BannerHandler),
	('/annotations', mapannotations.MapAnnotationHandler),
	('/annotation_editor', mapannotations.MapAnnotationEditorHandler),
	('/upload', photos.PhotoUploaderHandler),
	('/upload/complete', photos.PhotoUploadCompleteHandler),
	('/photos', photos.PhotoListHandler),
	webapp2.Route('/photos/<resource:(\w|-|_)+>/serve', handler=photos.PhotoServeHandler, name='photo-serve-handler')
]

app = webapp2.WSGIApplication(routes, debug=True)
