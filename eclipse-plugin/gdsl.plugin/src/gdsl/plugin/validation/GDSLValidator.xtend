package gdsl.plugin.validation

import gdsl.plugin.gDSL.CONS
import gdsl.plugin.gDSL.GDSLPackage
import gdsl.plugin.gDSL.Model
import gdsl.plugin.gDSL.PAT
import gdsl.plugin.preferences.GDSLPluginPreferences
import gdsl.plugin.properties.GDSLProjectProperties
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IPath
import org.eclipse.xtext.validation.Check

import static extension java.lang.Character.*

/**
 * Custom validation rules. 
 * 
 * @author Daniel Endress
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class GDSLValidator extends AbstractGDSLValidator {

	public static val UPPERCASE_CONS = 'uppercaseCons'
	public static val PATTERN_MISPLACEMENT = 'patternMisplacement'

	/**
	 * Check whether all constructors start with a captial letter
	 */
	@Check
	def upperCaseCons(CONS cons){
		if(!cons.conName.charAt(0).upperCase){
			error("Constructors have to start with a capital", 
				GDSLPackage::eINSTANCE.CONS_ConName,
				UPPERCASE_CONS,
				cons.conName
			);
		}
	}
	
	/**
	 * Checks whether a pattern is only used after a constructor
	 */
	@Check
	def patternOnlyForConstructors(PAT pat){
		if(null != pat.pat){
			if(!pat.id.charAt(0).upperCase){
				error("A pattern is only allowed for constructors",
					GDSLPackage::eINSTANCE.PAT_Pat,
					PATTERN_MISPLACEMENT,
					pat.id,
					text(pat.pat)
				)
			}
		}
	}
	
	private def String text(PAT pat){
		if(null != pat.uscore) return pat.uscore
		if(null != pat.int) return pat.int
		if(null != pat.id) return pat.id
		if(null != pat.bitpat) return "'" + pat.bitpat + "'"
	}

	/**
	 * Calls the external GDSL compiler for verification
	 */
	@Check
	def checkExternalCompiler(Model model){
		val resource = model.eResource
		if(!resource.trackingModification){
			// Set tracking modification to track whether the file has been modified
			resource.setTrackingModification(true)
		}
		if(resource.modified){
			return //Do not validate if changes not saved
		}
		
		val projectPath = GDSLProjectProperties.obtainProject(resource).location
		val workspaceRoot = ResourcesPlugin.workspace.root
		
		if(GDSLPluginPreferences.compilerEnablement){
			val commandBuilder = new StringBuilder()
			
			//Compiler invocation
			commandBuilder.append(GDSLPluginPreferences.compilerInvocation)
			
			//Output name
			commandBuilder.append(" -o " + GDSLProjectProperties.getOutputName(resource))
			
			//Runtime templates
			commandBuilder.append(" --runtime=" + GDSLProjectProperties.getRuntimeTemplates(resource))
			
			//Prefix
			val prefix = GDSLProjectProperties.getPrefix(resource)
			if(null != prefix){
				commandBuilder.append(" --prefix=" + prefix)
			}
			
			//Typechecker
			if(GDSLPluginPreferences.typeCheckerEnabled){
				commandBuilder.append(" --maxIter=" + GDSLPluginPreferences.typeCheckerIteration)
			} else {
				commandBuilder.append(" -t")
			}
			
			//Files
			commandBuilder.append(recursiveGetMLFiles(projectPath, workspaceRoot))
	
			//Call the compiler and set markers for the returned errors
			GDSLCompilerTools.compileAndSetMarkers(commandBuilder.toString, projectPath)
		} else {
			//Clear possible set markers
			GDSLCompilerTools.clearMarkers(projectPath)
		}
	}
		
	/**
	 * Builds a string containing all files found under the specified path with the extension .ml
	 * 
	 * @param path
	 * 			The path to search for files
	 * @param root
	 * 			The workspace root (ResourcesPlugin.getWorkspace().getRoot())
	 * @return
	 * 			A string containing all the files found separated by a space
	 */
	private def String recursiveGetMLFiles(IPath path, IWorkspaceRoot root){
		val container = root.getContainerForLocation(path);
		var result = new StringBuilder();
		try{
			for(IResource r : container.members){
				if("ml".equals(r.fileExtension)){
					result.append(" " + r.location.toOSString);
				}
				if(r.type == IResource.FOLDER){
					result.append(recursiveGetMLFiles(r.location, root));
				}
			}
		}
		catch(CoreException e){
		}
		return result.toString;
	}
}
