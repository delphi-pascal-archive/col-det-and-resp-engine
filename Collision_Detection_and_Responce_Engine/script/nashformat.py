#!BPY

# --------------------------------------------------
# Peremennie dlya dobavlenia knopki v menu Blender-a
# ==================================================

""" 
Name: 'Nash format...'
Blender: 241
Group: 'Export'
Tooltip: 'Nash format...'
"""

# ------------------------------------
# Informacia dlya polzovateley skripta
# ====================================

__author__ = ["Georgy Moshkin"]
__url__ = ("http://www.tmtlib.narod.ru")
__version__ = "1.0a"
__bpydoc__ = """\

Etot skript zapisivaet scenu v nash format. Prosto zapustite skript.

"""

# -----------------------
# Dobavlyaem nujnie uniti
# =======================

import Blender

# --------------------------
# Glavnaya procedura exporta
# ==========================

def my_export(filename):

	# -=((( Otrkoem file dlya zapisi )))=-

	myfile = open(filename, 'w')

	# -=((( Poluchim spisok obyektov tekushey sceni )))=-

	MYOBJECTS = Blender.Scene.GetCurrent().getChildren()

	# -=((( Proydemsa po vsem objektam )))=-

	# export Meshey
	for object in MYOBJECTS:
		if object.getType() != 'Mesh': continue
		print 'mesh:' + object.name
		mesh = object.getData()
                mesh.transform(object.matrix, True)
		faces = mesh.faces

		for face in faces:
  			myfile.write("face \n")

			if mesh.hasFaceUV(): myfile.write("%s \n" % face.image.name)
                        else: myfile.write("NOTEXTURE\n")

			myfile.write("%i \n" % len(face.v))

  			myfile.write("%f %f %f \n" % (face.v[0].co[0],face.v[0].co[1],face.v[0].co[2]))
  			myfile.write("%f %f %f \n" % (face.v[1].co[0],face.v[1].co[1],face.v[1].co[2]))
  			myfile.write("%f %f %f \n" % (face.v[2].co[0],face.v[2].co[1],face.v[2].co[2]))
 	     		if len(face.v) == 4: 
	 	 			myfile.write("%f %f %f \n" % (face.v[3].co[0],face.v[3].co[1],face.v[3].co[2]))
			
  			myfile.write("%f %f %f \n" % (face.v[0].no[0],face.v[0].no[1],face.v[0].no[2]))
  			myfile.write("%f %f %f \n" % (face.v[1].no[0],face.v[1].no[1],face.v[1].no[2]))
  			myfile.write("%f %f %f \n" % (face.v[2].no[0],face.v[2].no[1],face.v[2].no[2]))
 	     		if len(face.v) == 4: 
	 	 			myfile.write("%f %f %f \n" % (face.v[3].no[0],face.v[3].no[1],face.v[3].no[2]))


			vertidx = 0
			if mesh.hasFaceUV():
				while (vertidx<len(face.uv)):
					myfile.write("%f %f \n" % (face.uv[vertidx][0],face.uv[vertidx][1]))
					vertidx = vertidx +1
				
			myfile.write("\n")


	# export Lamp
	for object in MYOBJECTS:
		if object.getType() != 'Lamp': continue
		print 'lamp:' + object.name

	# export Camer
	for object in MYOBJECTS:
		if object.getType() != 'Camera': continue
		print 'camera:' + object.name
			
	myfile.close() 

# --------------------------------------------
# Vizivaem okno vibora imeni faila dlya zapisi
# ============================================

Blender.Window.FileSelector(my_export, "Export v nash format")