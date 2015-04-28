import xml.etree.ElementTree as ET
import sys
import subprocess
import utm
from math import sqrt
import json

defaultSpeed = 30
defaultLanes = 1

defaultSpeeds = {'beinside' : {'unclassified' : 50, 'primary' : 50, 'tertiary' : 50, 'residential' : 50, 'secondary' : 50, 'motorway_link' : 70, 'primary_link' : 50, 'living_street' : 20, 'default' : 30},
'beoutside' : {'unclassified' : 90, 'primary' : 90, 'tertiary' : 90, 'residential' : 90, 'secondary' : 90, 'motorway_link' : 70, 'primary_link' : 90, 'living_street' : 20, 'default' : 50}}
defaultpos = 'beinside'

class Road:
	def __init__(self, _name, sl, lanes, _rId, _roundabout):
		self.name = _name
		self.speedLimit = sl
		self.nbLanes = lanes
		self.myId = _rId
		self.roundabout = _roundabout
	def __str__(self):
		return self.name+" ("+str(self.speedLimit)+"kph ; "+str(self.nbLanes)+" lanes)"
	def toDic(self):
		return {"name" : self.name, "speedLimit" : self.speedLimit, "nbBands" : self.nbLanes}
	def equals(self,r):
		return self.myId == r.myId or (self.name == r.name and self.speedLimit == r.speedLimit and self.nbLanes == r.nbLanes and self.roundabout==r.roundabout)

class RoadSegment(Road):
	def __init__(self, r, _startId, _endId, l):
		super().__init__(r.name,r.speedLimit,r.nbLanes, r.myId, r.roundabout)
		self.startId = _startId
		self.endId = _endId
		self.length = l
	
	def toDic(self,idMap):
		dic = super().toDic()
		dic['startId'] = idMap[self.startId]
		dic['endId'] = idMap[self.endId]
		dic['length'] = self.length
		return dic		
	
	def doConcat(self,nodes):
		res=False
		if not nodes[self.endId].isIntersection():
			endNIds = list(nodes[self.endId].neighbors.keys())
			if len(endNIds) == 1 and endNIds[0] != self.startId:
				res=True
				r = nodes[self.endId].popNeighbor(endNIds[0])
				self.length += r.length
				self.endId = r.endId
			if len(endNIds) == 2:
				i=3
				if endNIds[0] == self.startId and endNIds[1] != self.startId:
					i = 1
				elif endNIds[0] != self.startId and endNIds[1] == self.startId:
					i = 0
				if i != 3 :
					res=True
					r = nodes[self.endId].popNeighbor(endNIds[i])
					self.length += r.length
					self.endId = r.endId
				
		return res
				
		

class Node:
	def __init__(self, xy, i):
		self.neighbors = {}
		self.myId = i
		self.coords = xy
		self.type = 0
		self.linkedRoads = []

	def addNeighbor(self,neigh,r):
		#if not r.myId in self.linkedRoads:
		if not self.linkedTo(r):
			self.linkedRoads.append(r)
		self.neighbors[neigh.myId] = RoadSegment(r,self.myId,neigh.myId,self.dist(neigh))
	
	def linkedTo(self, r):
		for linkedRoad in self.linkedRoads:
			if r.equals(linkedRoad):
				return True
		return False

	def addOneway(self,r):
		#if not r.myId in self.linkedRoads:
		if not self.linkedTo(r):
			self.linkedRoads.append(r)

	def dist(self, otherNode):
		return (sqrt((self.coords[0]-otherNode.coords[0])**2 + (self.coords[1]-otherNode.coords[1])**2))/1000.0
	
	def popNeighbor(self,nId):
		if nId in self.neighbors:
			r = self.neighbors.pop(nId)
			stillPresent = False
			for nId2 in self.neighbors:
				if self.neighbors[nId2].equals(r):
					stillPresent = True
					break
			if not stillPresent:
				for i in range(len(self.linkedRoads)):
					if self.linkedRoads[i].equals(r):
						self.linkedRoads.pop(i)
						break
				#self.linkedRoads.pop(self.linkedRoads.index(r.myId))
			return r

	def isIntersection(self):
		return len(self.linkedRoads)>1
	
	def toDic(self,idMap):
		return {'type' : self.type, 'x' : self.coords[0], 'y' : self.coords[1], 'id' : idMap[self.myId]}
	
	def tryConcat(self,nodes):
		res = False
		over = False
		while not over:
			over = True
			for nId in self.neighbors:
				if self.neighbors[nId].doConcat(nodes):
					self.neighbors[self.neighbors[nId].endId] = self.neighbors[nId]
					del self.neighbors[nId]
					res = True
					over = False
					break
		
		return res
	
	def usefull(self):
		#return True
		return len(self.neighbors) > 0
	
	def remap(self,old,new):
		if old in self.neighbors:
			r = self.neighbors[old]
			del self.neighbors[old]
			self.neighbors[new] = r

def main(argv=None):
	#parse the arguments
	if argv is None:
		argv = sys.argv
	if len(argv) < 2 :
		print("Usage : requires input file path")
		return(0)
	inputFilePath = argv[1]
	outputFilePath = inputFilePath
	if outputFilePath.endswith(('.osm','.o5m','.xml')):
		outputFilePath = outputFilePath[:-4]
		outputFilePath+="_parsed.json"
	
	if '-o' in argv:
		oIndex = argv.index('-o')
		if len(argv) > oIndex+1:
			outputFilePath = argv[oIndex+1]
	
	pos = defaultpos
	if '-pos' in argv:
		pIndex = argv.index('-pos')
		if len(argv) > pIndex+1:
			if(argv[pIndex+1] in defaultSpeeds):
				pos = argv[pIndex+1]
			else:
				print("WARNING: Tried to set position to '"+argv[pIndex+1]+"' but that is not a valid option")
	
	filterPath="filter"
	if '-filter' in argv:
		fIndex = argv.index('-filter')
		if len(argv) > fIndex+1:
			filterPath = argv[fIndex+1]

	print("Input file:\t"+inputFilePath+"\nOutput file:\t"+outputFilePath)
	
	#filter input file
	print("Applying filter to input...")
	cmd="osmfilter "+inputFilePath+" --parameter-file="+filterPath
	filteredXML = subprocess.check_output(cmd, shell=True)
	print("... Done")
	
	print("Parsing filtered input...")
	
	#parse the filtered xml file:
	#tree = ET.parse(inputFilePath)
	#root = tree.getroot()
	root = ET.fromstring(filteredXML)
	
	#find bounds
	bounds = root.find('bounds')
	maxlon = float(bounds.attrib['maxlon'])
	maxlat = float(bounds.attrib['maxlat'])
	minlon = float(bounds.attrib['minlon'])
	minlat = float(bounds.attrib['minlat'])
	
	maxPoint = utm.from_latlon(maxlat, maxlon)[:2]
	minPoint = utm.from_latlon(minlat, minlon)[:2]
	diffY = maxPoint[1]-minPoint[1]

	all_nodes={}
	nodeI=0
	#parse nodes
	for node in root.findall('node'):
		point = utm.from_latlon(float(node.attrib['lat']),float(node.attrib['lon']))[:2]
		all_nodes[node.attrib['id']]=Node( (point[0]-minPoint[0],diffY-(point[1]-minPoint[1])), node.attrib['id'])
		#all_nodes[node.attrib['id']]=Node( (point[0]-minPoint[0],diffY-(point[1]-minPoint[1])), nodeI)
		#all_nodes[node.attrib['id']]=Node( (point[0]-minPoint[0],point[1]-minPoint[1]), nodeI)
		nodeI += 1
	print(str(len(all_nodes))+" nodes were found")
	roads = {}
	#parse ways
	for way in root.findall('way'):
		rdId = way.attrib['id']
		speed = defaultSpeed
		name = ""
		tags = {}
		nbLanes = defaultLanes
		for tag in way.findall('tag'):
			tags[tag.attrib['k']] = tag.attrib['v']
		if 'name' in tags:
			name = tags['name']
		else:
			name = str(tags)
		if 'lanes' in tags:
			nbLanes = int(tags['lanes'])
		if 'maxspeed' in tags:
			speed = int(tags['maxspeed'])
		elif pos in defaultSpeeds:
			if tags['highway'] in defaultSpeeds[pos]:
				speed = defaultSpeeds[pos][tags['highway']]
			else:
				speed = defaultSpeeds[pos]['default']
		roundabout = 'junction' in tags and tags['junction'] == 'roundabout'
		oneway = ('oneway' in tags and tags['oneway']=='yes') or (roundabout)
		roads[rdId] = Road(name,speed,nbLanes,rdId,roundabout)		

		nds = []
		for nd in way.findall('nd'):
			nds.append(nd.attrib['ref'])
		for i in range(len(nds)-1):
			all_nodes[nds[i]].addNeighbor(all_nodes[nds[i+1]],roads[rdId])
			if not oneway:
				all_nodes[nds[i+1]].addNeighbor(all_nodes[nds[i]],roads[rdId])
			else:
				all_nodes[nds[i+1]].addOneway(roads[rdId])
	#print(len(roads))
	rSeg_count = 0
	for nId in all_nodes:
		rSeg_count+=len(all_nodes[nId].neighbors)
	#print(i_count)
	print(str(rSeg_count)+" individual road (segment) found")
	print("... Done")
	
	print("Grouping neighboring nodes that are not intersections...")
	concat = True
	while concat:
		concat = False
		for nId in all_nodes:
			concat = all_nodes[nId].tryConcat(all_nodes) or concat
	
	print("... remapping nodes ids ...")
	usefullCounter = 0
	usefullRdCounter = 0
	nIdMap = {}
	inv_nIdMap = []
	for nId in all_nodes:
		if all_nodes[nId].usefull():
			if not nId in nIdMap:
				nIdMap[nId] = usefullCounter
				inv_nIdMap.append(nId)
				usefullCounter+=1
			
			for neighId in all_nodes[nId].neighbors:
				usefullRdCounter+=1
				if not neighId in nIdMap:
					nIdMap[neighId] = usefullCounter
					inv_nIdMap.append(neighId)
					usefullCounter+=1
			
	print("... Done: reduced number of nodes to "+str(usefullCounter)+" and number of roads to "+str(usefullRdCounter))
	#create json data
	json_data = {}
	json_data['metric']=1
	json_nodes = []
	json_roads = []
	for i in range(len(inv_nIdMap)):
		nId = inv_nIdMap[i]
		json_nodes.append(all_nodes[nId].toDic(nIdMap))
		for neighId in all_nodes[nId].neighbors:
			json_roads.append(all_nodes[nId].neighbors[neighId].toDic(nIdMap))
	json_data['nodes']=json_nodes
	json_data['roads']=json_roads
	
	#Writing output
	print("Writing output to "+outputFilePath+" ...")
	with open(outputFilePath, 'w') as outfile:
		json.dump(json_data, outfile, sort_keys = True, indent = 2, ensure_ascii = False)
	print("All done !")
	return(1)

if __name__ == "__main__":
	sys.exit(main())
