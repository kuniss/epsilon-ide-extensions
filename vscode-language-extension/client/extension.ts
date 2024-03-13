/*
 * Copyright (C) 2019 GrammarCraft and others.
 *
 * Licensed under the Eclipse Public License - v 2.0 (the "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at https://www.eclipse.org/legal/epl-2.0/
 */

'use strict';

import * as path from 'path';
import * as os from 'os';
import {
    workspace,
    commands,
    Uri,
    ExtensionContext
} from 'vscode';
import {
    LanguageClient,
    LanguageClientOptions,
    ServerOptions,
    Position as LSPosition, Location as LSLocation
} from 'vscode-languageclient';

export function activate(context: ExtensionContext) {

    // The server is implemented in Xtext
    let executable = os.platform() === 'win32' ? 'de.grammarcraft.epsilon.ide.bat' : 'de.grammarcraft.epsilon.ide';
    let serverModule = context.asAbsolutePath(path.join('server', 'bin', executable));

    let env = process.env

    env['JAVA_OPTS'] = ''
    let runCompilerGenerator = workspace.getConfiguration().get('eag.runCompilerGenerator')
    if (runCompilerGenerator !== undefined) {
        env['JAVA_OPTS'] += ' -Dde.grammarcraft.epsilon.skipExecution=' + !runCompilerGenerator 
    }

    let codeGenerationOnly = workspace.getConfiguration().get('eag.compilerGenerator.codeGenerationOnly')
    if (codeGenerationOnly !== undefined) {
        env['JAVA_OPTS'] += ' -Dde.grammarcraft.epsilon.codeGenerationOnly=' + codeGenerationOnly 
    }

    let epsilonExecutable = workspace.getConfiguration().get('eag.compilerGenerator.executable')
    if (epsilonExecutable && epsilonExecutable !== '') {
        env['JAVA_OPTS'] += ` -Dde.grammarcraft.epsilon.executable="${epsilonExecutable}"`
    }

    let useExternalExecutable = workspace.getConfiguration().get('eag.compilerGenerator.useExternalExecutable')
    if (useExternalExecutable !== undefined) {
        env['JAVA_OPTS'] += ' -Dde.grammarcraft.epsilon.useExternalExecutable=' + useExternalExecutable
    }

    let epsilonEvaluatorType = workspace.getConfiguration().get<string>('eag.compilerGenerator.evaluatorGeneratorType')
    if (epsilonEvaluatorType && epsilonEvaluatorType !== '') {
        env['JAVA_OPTS'] += ` -Dde.grammarcraft.epsilon.evaluatorGeneratorType="${epsilonEvaluatorType}"`
    }

    let epsilonTargetDir = workspace.getConfiguration().get('eag.compilerGenerator.targetDir')
    if (epsilonTargetDir && epsilonTargetDir !== '') {
        env['JAVA_OPTS'] += ` -Dde.grammarcraft.epsilon.target.dir="${epsilonTargetDir}"`
    }

    let additionalExeOptions = workspace.getConfiguration().get('eag.compilerGenerator.additionalExeOptions')
    if (additionalExeOptions && additionalExeOptions !== '') {
        env['JAVA_OPTS'] += ` -Dde.grammarcraft.epsilon.additionalExeOptions="${additionalExeOptions}"` 
    }

    let logLevel = workspace.getConfiguration().get<string>('eag.compilerGenerator.logLevel')
    var additonalArgs: string[] = []
    if (logLevel != "OFF") {
         additonalArgs = ['-log']
         env['JAVA_OPTS'] += ` -Dde.grammarcraft.epsilon.logLevel="${logLevel}"` 
    }

    console.log("JAVA_OPTS: " + env['JAVA_OPTS'])

    // If the extension is launched in debug mode then the debug server options are used
    // Otherwise the run options are used
    let serverOptions: ServerOptions = {
        run: {
            command: serverModule,
            args: additonalArgs,
            options: env
        },
        debug: {
            command: serverModule,
            args: ['-Xdebug', '-Xrunjdwp:server=y,transport=dt_socket,address=8000,suspend=n,quiet=y', '-Xmx256m'].concat(additonalArgs),
            options: env
        }
    }

    // Options to control the language client
    let clientOptions: LanguageClientOptions = {
        // Register the server for plain text documents
        documentSelector: [
            { language: 'epsilon', pattern: '**/*.{eag,epsilon}' },
            { language: 'epsilon', scheme: 'file' },
            { language: 'epsilon', scheme: 'untitled' }
        ],
        synchronize: {
            // Notify the server about file changes to *.eps and *.epsilon files contain in the workspace
            fileEvents: workspace.createFileSystemWatcher('**/*.{eag,eps,epsilon}')
        }
    }

    // Create the language client and start the client.
    let languageClient = new LanguageClient('epsilonEagLanguageServer', 'EAG Language Server', serverOptions, clientOptions);
    let disposable = languageClient.start()

    commands.registerCommand('epsiloneag.show.references', (uri: string, position: LSPosition, locations: LSLocation[]) => {
        commands.executeCommand('editor.action.showReferences',
                    Uri.parse(uri),
                    languageClient.protocol2CodeConverter.asPosition(position),
                    locations.map(languageClient.protocol2CodeConverter.asLocation));
    })

    commands.registerCommand('epsiloneag.apply.workspaceEdit', (obj) => {
        let edit = languageClient.protocol2CodeConverter.asWorkspaceEdit(obj);
        if (edit) {
            workspace.applyEdit(edit);
        }
    });

    // Push the disposable to the context's subscriptions so that the 
    // client can be deactivated on extension deactivation
    context.subscriptions.push(disposable);
}
