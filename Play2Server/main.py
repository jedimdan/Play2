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
from datetime import datetime
from random import randrange

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

class Photo(db.Model):
	blob_key = blobstore.BlobReferenceProperty()
	caregroup_name = db.StringProperty()
	datetime_taken = db.DateTimeProperty()
	approved = db.BooleanProperty(default=False)

	def to_dict(self):
		return_dict = dict([(p, getattr(self, p)) for p in self.properties()])
		return_dict['id'] = self.key().id()
		return return_dict

class PhotoUploaderHandler(webapp2.RequestHandler):
	def get(self):
		if randrange(5) < 4:
			upload_url = blobstore.create_upload_url('/upload/complete')
			self.response.out.write(upload_url)
		else:
			# designed to fail 20% of the time to test failure on the iOS client
			self.response.out.write('http://this.is.a.test.corrupted.url')

class PhotoUploadCompleteHandler(blobstore_handlers.BlobstoreUploadHandler):
	def post(self):
		the_blob = self.get_uploads('image_file')[0]  # 'file' is file upload field in the form

		image_date_str = self.request.get('image_date')
		# format from iOS is 2012:05:23 17:51:33
		image_date = datetime.strptime(image_date_str, '%Y:%m:%d %H:%M:%S')
		new_photo = Photo(blob_key=the_blob.key(), caregroup_name=self.request.get('cg_name'), datetime_taken=image_date)
		
		new_photo.put()

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
