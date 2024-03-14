package de.grammarcraft.epsilon.validation

import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import org.apache.log4j.Logger

class ResourceExtractor {
    static val log = Logger.getLogger(EpsilonExecutor.name)
    
    static val READ_BUFFER_LEN = 4096
    static val D_LIB_SOURCES = #["include/runtime.d", "src/io.d", "src/log.d", "src/epsilon/soag/listacks.d"]
    
    def static extractExecutableFromJarTo(File targetDir) {
    	val exeName = executableName()
        if (extractResourceFromJar("/native/" + osResourceDir + "/", exeName, targetDir)) {
        	val exeFile = new File(targetDir, exeName)
			if (isLinux || isMacOS)
				exeFile.executable = true
       		log.info('''compiler generator executable successfully extracted to '«exeFile.path»' ''')			
        }
        else
       		log.warn('''failed to extract executable '«exeName»' - deeper semantic verification will be missed''')
    }
    
    def static extractDLibSourcesFromJarTo(File targetDir) {
        for (resource : D_LIB_SOURCES) {
        	if (extractResourceFromJar("/src-dlang/", resource, targetDir))
        		log.info('''resource '«resource»' successfully extracted to '«targetDir.path»' ''')			
        		
        	else
        		log.warn('''failed to extract resource '«resource»' - generated D source may fail to compile''')
        }
    }
    
    def private static boolean extractResourceFromJar(String resourceDir, String resourceName, File targetDir) {
		val targetFile = new File(targetDir, resourceName)
		
		if (targetFile.exists) {
			log.info('''extracting resource '«resourceDir»«resourceName»' from JAR skipped, as it already exists''')
			return true
		}
    	
		if (!targetDir.mkDirsIfNotExisting)
			return false

        try(val input = ResourceExtractor.getResourceAsStream(resourceDir + resourceName)) {
        	if (input === null) {
        		log.error('''resource '«resourceDir»«resourceName»' does not exist''')
        		return false
        	}
        	
			if (!targetFile.parentFile.mkDirsIfNotExisting)
				return false
				
            try(val output = new FileOutputStream(targetFile)) {
                var int readBytes
				val buffer = newByteArrayOfSize(READ_BUFFER_LEN)
                while ((readBytes = input.read(buffer)) > 0) {
                    output.write(buffer, 0, readBytes);
                }
            }
        }
        catch (IOException ioe) {
            log.error("failed to export resource from JAR: " + ioe.message)
            return false;
        }
        return true
    }
    
    def private static boolean  mkDirsIfNotExisting(File filePath) {
    	if (!filePath.exists) {
    		try {
				if (!filePath.mkdirs) {
					log.error('''failed to created directories on path «filePath.absolutePath»''')
					return false
				}
				else // dirs successfully created
					return true   			
    		}
    		catch (SecurityException se) {
				log.error('''failed to created directories on path «filePath.absolutePath»: «se.message»''')
				return false
    		}
    	}
    	else if (!filePath.isDirectory) {
			log.error('''failed to created directories on path «filePath.absolutePath» as it is a ordinary file''')
			return false    		
    	}
    	else // is an existing directory 
			return true    	
    }
    
    def static isWindows() {
		System.getProperty("os.name").toLowerCase().startsWith("windows");    	
    }
    
    def private static isLinux() {
		System.getProperty("os.name").toLowerCase().startsWith("linux");    	
    }

    def private static isMacOS() {
		System.getProperty("os.name").toLowerCase().startsWith("macos");    	
    }
    
    def private static executableName() {
    	if (isWindows)
    		"gamma.exe"
    	else
    		"gamma"
    }
    
    def static osResourceDir() {
    	if (isLinux)
    		"linux"
    	else if (isWindows)
    		"windows"
    	else if (isMacOS)
    		"macos"
    	else
    		"unkownOS"
    }
}