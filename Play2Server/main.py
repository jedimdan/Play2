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
import jinja2
import os
import urllib
from google.appengine.ext import db
from google.appengine.ext import blobstore
from google.appengine.ext.webapp import blobstore_handlers
import djangoforms
import logging

jinja_environment = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)))

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

class PhotoUploaderHandler(webapp2.RequestHandler):
	def get(self):
		upload_url = blobstore.create_upload_url('/upload/complete')
		self.response.out.write(upload_url)

class PhotoUploadCompleteHandler(blobstore_handlers.BlobstoreUploadHandler):
	def post(self):
		upload_files = self.get_uploads('image_file')  # 'file' is file upload field in the form
		blob_info = upload_files[0]
		logging.info(blob_info)

		args = self.request.arguments()
		logging.info('lalala')
		logging.info(args)

		bod = self.request.body
		logging.info('body')
		logging.info(bod)

class MapAnnotation(db.Model):
	coords = db.GeoPtProperty()
	title = db.StringProperty()
	subtitle = db.StringProperty()
	image_url = db.LinkProperty()

	def to_dict(self):
		return_dict = dict([(p, getattr(self, p)) for p in self.properties()])
		return_dict['id'] = self.key().id()
		return_dict['coords'] = {'lat': self.coords.lat, 'lon': self.coords.lon}
		return return_dict

class MapAnnotationForm(djangoforms.ModelForm):
    class Meta:
        model = MapAnnotation

class MapAnnotationHandler(webapp2.RequestHandler):
	def get(self):
		annotations = MapAnnotation.all().fetch(100)
		self.response.headers['Content-Type'] = 'application/json'
		self.response.out.write(json.dumps([annotation.to_dict() for annotation in annotations], indent=4))

class MapAnnotationEditorHandler(webapp2.RequestHandler):
	def get(self):
		annotations = MapAnnotation.all().fetch(100)
		template = jinja_environment.get_template('annotations.html')
		self.response.out.write(template.render({'form': MapAnnotationForm(), 'annotations': [annotation.to_dict() for annotation in annotations]}))

	def post(self):
		data = MapAnnotationForm(data=self.request.POST)
		if data.is_valid():
			entity = data.save(commit=False)
			entity.put()
			self.redirect('/annotation_editor')
		else:
			annotations = MapAnnotation.all().fetch(100)
			template = jinja_environment.get_template('annotations.html')
			self.response.out.write(template.render({'form': data, 'annotations': [annotation.to_dict() for annotation in annotations]}))

routes = [
	('/', MainHandler),
	('/banners', Play2BannerHandler),
	('/annotations', MapAnnotationHandler),
	('/upload', PhotoUploaderHandler),
	('/upload/complete', PhotoUploadCompleteHandler),
	('/annotation_editor', MapAnnotationEditorHandler),

]

app = webapp2.WSGIApplication(routes,
                              debug=True)
