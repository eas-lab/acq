#pragma rtGlobals=3		// Use modern global access method and strict wave access.


Structure RectSize
	uint32 DimX
	uint32 DimY
EndStructure

Structure VideoSettingsStatic
	uint32 Binning
	uint32 RoiX
	uint32 RoiY
	uint32 RoiWidth
	uint32 RoiHeight
	uint32 TriggerMode
EndStructure


Function test_CcdCam_Acquire()
	VARIABLE device, frameNum

	STRUCT RectSize size
	STRUCT VideoSettingsStatic settings

	//
	// Ensure system is in a known good state:
	//

	CcdCam_Reset(); AbortOnRTE
	// use AbortOnRTE statement to ensure that
	// the function aborts if this call fails
	print "Reset successful"

	//
	// Initialize the CCD camera device:
	//

	// Valid camera device types:
	// 0 = fake
	// 1 = QCam
	// 2 = Orca ER
	device = 0
	CcdCam_Create(device); AbortOnRTE
	print "Device created"

	//
	// Request the CCD size
	//
	CcdCam_GetSize(device, size); AbortOnRTE
	print "Full CCD size is", size.DimX, "x", size.DimY


	//
	// Set up the acquisition parameters
	//
	settings.Binning = 1
	settings.RoiX = 16
	settings.RoiY = 32
	settings.RoiWidth = 256
	settings.RoiHeight = 128

	// valid trigger modes:
	// Freerun = 0
	// Software = 1
	// HardwareEdgeHigh = 2
	// HardwareEdgeLow = 4
	settings.Triggermode = 0

	CcdCam_SetVideoSettingsStatic(device, settings); AbortOnRTE
	print "Video settings set"

	//
	// Create a 2D wave to hold the aquired frames
	//
	Make/N=(settings.RoiWidth,settings.RoiHeight)/W/U/O frame; AbortOnRTE
	print "Frame buffer created"

	//
	// Start acquiring frames
	//
	CcdCam_Start(device); AbortOnRTE
	print "Started acquisition"

	//
	// Load in some frames
	//
	frameNum = CcdCam_TryGetFrame(device, frame); AbortOnRTE
	print "Frame", frameNum, "has wavestats"
	WaveStats frame

	frameNum = CcdCam_TryGetFrame(device, frame); AbortOnRTE
	print "Frame", frameNum, "aquired"

	frameNum = CcdCam_TryGetFrame(device, frame); AbortOnRTE
	print "Frame", frameNum, "aquired"

	//
	// Stop acquiring frames
	//
	CcdCam_Stop(device)
	print "Stopped acquisition"

	CcdCam_Reset()
	print "Device reset"
End
