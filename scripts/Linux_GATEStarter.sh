//#!/usr/bin/env groovy

// example command line that will run the ANNIE tokeniser over all documents in the input folder and store the results in output
//    groovy runGATE.sh "uk.ac.gate.plugins:annie:8.5-SNAPSHOT" gate.creole.tokeniser.DefaultTokeniser input output

println 'GATE Executor...'

@GrabResolver(name='gate-snapshots', root='http://repo.gate.ac.uk/content/groups/public/')
@Grab(group='uk.ac.gate', module='gate-core', version='8.5.1')
import gate.*;
import gate.creole.*;
import gate.util.persistence.PersistenceManager;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.TrueFileFilter;

println 'Started GATE Initilization'
//Initialise GATE: must be done before you try and use any part of GATE
Gate.init();
println 'GATE was initialized'

// Assumes the following command line arguments:
//    Maven coordinates of the plugin to load initially
//    Classname of the component to create and use
//    input file path
//    output file path
// after these mandatory arguments you can specify params passed to the
// component using any number of arguments of the form:
//    -Pparameter=value

// Get a handle on the Maven based plugin we need to load to run this component
String[] coordinates = args[0].split(":");
Plugin plugin = new Plugin.Maven(coordinates[0],coordinates[1],coordinates[2]);

println coordinates[0];
println coordinates[1];
println coordinates[2];
println args[1];

println 'Starting Plugin Registration.'
// load the plugin into GATE...
Gate.getCreoleRegister().registerPlugin(plugin);

File input = new File(args[2]);
File output = new File(args[3]);

println 'Process Component Parameters'
FeatureMap params = Factory.newFeatureMap();

for (int i = 4 ; i < args.length ; ++i) {
	if (args[i].startsWith("-P")) {
		String[] param = args[i].substring(2).split("=",2);
		params.put(param[0],param[1]);
	}
}

println params;

// sanity check time
output.mkdirs();

println 'Create Component'
// create an pipeline to which  we can add the processing resource we are being asked to run
ConditionalSerialAnalyserController app = (ConditionalSerialAnalyserController)Factory.createResource("gate.creole.ConditionalSerialAnalyserController");

// create and add the processing resource to the pipeline
app.add((ProcessingResource)Factory.createResource(args[1],params));

// create a corpus and add the document to it
Corpus corpus = Factory.newCorpus();

Document doc = null;

// tell the app which corpus to run over
app.setCorpus(corpus);

// export the result as GATE XML to the specified output file
DocumentExporter exporter = DocumentExporter.getInstance("gate.corpora.export.GateXMLExporter");

println 'Start processing'

// iterate through the input folder to find all the files for processing
Iterator<File> itInputFiles = FileUtils.iterateFiles(input, TrueFileFilter.INSTANCE, TrueFileFilter.INSTANCE);
while (itInputFiles.hasNext()) {

	// for each input file....
	File inputFile = itInputFiles.next();

	println '\t'+inputFile.getAbsolutePath();

	try {
		// load the document
		doc = Factory.newDocument(inputFile.toURI().toURL())

		// add it to the corpus
		corpus.add(doc);

		// run the app over the corpus
		app.execute();

		// build the output filename
		File outputFile = new File(output, input.toURI().relativize(inputFile.toURI()).toString()+"."+exporter.getDefaultExtension());

		// make sure the parent directory tree exists
		outputFile.getParentFile().mkdirs();

		// export the processed document
		exporter.export(doc, outputFile);
	}
	finally {
		//clean up the document no matter what happened
		corpus.remove(doc);
		if (doc != null) Factory.deleteResource(doc);
	}
}

println "Finished"

