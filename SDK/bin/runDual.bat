if "%ComputerName%" =="C6_V1_HEAD" (
	start S:\apps\dual_test\VMD\SDK\bin\FionaVMD.exe configFile C:\Users\Admin2\Desktop\FionaConfigDual.txt navigationSpeed 0.02 rotationSpeed 0.015
) else (
	start S:\apps\dual_test\VMD\SDK\bin\FionaVMD.exe configFile C:\Users\Admin2\Desktop\FionaConfigDP.txt windowX 0 windowY 0 windowW 1920 windowH 1920 navigationSpeed 0.02 rotationSpeed 0.015 kevinOffset -0.033 -0.0266 0.041
	TIMEOUT 3 
	start S:\apps\dual_test\VMD\SDK\bin\FionaVMD.exe configFile C:\Users\Admin2\Desktop\FionaConfigDP.txt windowX 1920 windowY 0 windowW 1920 windowH 1920 navigationSpeed 0.02 rotationSpeed 0.015 kevinOffset 0.033 -0.0266 0.041
)

