from google.appengine.ext import db
from google.appengine.ext import blobstore
from google.appengine.ext.webapp import blobstore_handlers
from datetime import datetime
from random import randrange
import webapp2
import json
import urllib

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

class PhotoListHandler(webapp2.RequestHandler):
	def get(self):
		caregroup_filter = self.request.get('cg')
		limit = self.request.get('limit', default_value=10)

		query = Photo.all().order('-datetime_taken')
		if caregroup_filter:
			query = query.filter('caregroup_name', caregroup_filter)
		photos = query.run(limit=int(limit))

		dthandler = lambda obj: obj.isoformat() if isinstance(obj, datetime) else None
		self.response.headers['Content-Type'] = 'application/json'
		self.response.out.write(json.dumps([self.modify_photos_dict_to_include_blob_url(photo.to_dict()) for photo in photos], default=dthandler, indent=4))

	def modify_photos_dict_to_include_blob_url(self, photos_dict):
		blobkey = photos_dict['blob_key'].key()
		del photos_dict['blob_key']
		photos_dict['blob_serving_url'] = self.blob_url_for_blobkey(blobkey)
		return photos_dict

	def blob_url_for_blobkey(self, blobkey):
		return self.uri_for('photo-serve-handler', resource=blobkey, _full=True)

class PhotoServeHandler(blobstore_handlers.BlobstoreDownloadHandler):
	def get(self, resource):
		resource = str(urllib.unquote(resource))
		blob_info = blobstore.BlobInfo.get(resource)
		self.send_blob(blob_info)
