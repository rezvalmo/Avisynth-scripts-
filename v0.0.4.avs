SetMemoryMax(8192)
global threads=8
LoadPlugin("C:\Windows\svpflow1.dll")
LoadPlugin("C:\Windows\svpflow2.dll")


SetFilterMTMode("DEFAULT_MT_MODE",4)
SetFilterMTMode("SVSuper",2)
SetFilterMTMode("SVAnalyse",2)
SetFilterMTMode("SVSmoothFps",2)
global source_width = width
global source_height = height
global crop_string  = ""
global resize_string = ""
global super_params     = "{pel:1,scale:{up:2,down:4},gpu:1}}"
global analyse_params   = "{block:{w:32,h:32,overlap:1},gpu:1,vectors:3,main:{search:{type:4,coarse:{width:2160,type:4,sort:true,distance:-1,bad:{sad:9000000,range:99999999}}}},refine:[{thsad:150,width:99999999}]}"
global smoothfps_params = "{gpuid:11,rate:{num:5,den:2,abs:false},algo:2,mask:{area:-1},scene:{mode:0}}"
global demo_mode=0
global stereo_type=0
global nvof=0
function interpolate(clip src)
{
	input = crop_string=="" ? src : eval("src."+crop_string)
	input = resize_string=="" ? input : eval("input."+resize_string)
	#MT-MODE-1  #do not remove this line!
	super=SVSuper(input, super_params)
	vectors=SVAnalyse(super, analyse_params, src=input)
	smooth=SVSmoothFps(input, super, vectors, smoothfps_params, mt=60, src=src)
	#MT-MODE-2  #do not remove this line!
	return demo_mode==0 ? smooth : demo(input,smooth)
}
input=last
	stereo_type==0 ? eval(""" interpolate(input)
""") : 	stereo_type==1 ? eval("""
		lf = interpolate(input.crop(0,0,input.width/1,0))
		rf = interpolate(input.crop(input.width/1,0,0,0))
		StackHorizontal(lf, rf)
""") : 	stereo_type==2 ? Eval("""
		lf = interpolate(input.crop(0,0,0,input.height/1))
		rf = interpolate(input.crop(0,input.height/1,0,0))
		StackVertical(lf, rf)""") : input

	


Prefetch(24)