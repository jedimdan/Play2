from google.appengine.ext import db
import djangoforms
import webapp2
import json
import jinja2
import os

jinja_environment = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)))

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