import Component from "@glimmer/component";
import {tracked} from "@glimmer/tracking";
import {inject as service} from "@ember/service";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import dIcon from "discourse-common/helpers/d-icon";
import {action} from "@ember/object";


export default class BugReportInstructionsModal extends Component {
    @service siteSettings;
    @tracked dontShowAgain = false;

    localStorageKey = undefined;

    guidelines = [
        { id: 1, text: "Respond in English." },
        { id: 2, text: "Attach a picture/video showing the bug." },
        { id: 3, text: "Include log files:", subItems: [
                "Player.log and Player-prev.log",
                "DataStore folder: %USERPROFILE%\\AppData\\LocalLow\\Moon Studios\\NoRestForTheWicked"
            ]},
        { id: 4,
            text: "If you experience crashes, include files from: %USERPROFILE%\\AppData\\LocalLow\\Moon Studios\\NoRestForTheWicked\\backtrace\\crashpad\\reports" },
        { id: 5, text: "Include the dxdiag file:", subItems: [
                "Press the Windows key, type dxdiag, and run the program",
                "Click 'Save All Information'",
                "Save the file to a path"
            ]},
        { id: 6,
            text: "Upload these files to an external site (e.g., WeTransfer, Google Drive) and link in your report." },
        { id: 7, text: "Answer:", subItems: [
                "Were you able to reproduce the bug?",
                "Where did it occur?",
                "Has it been reported before?"
            ]},
        { id: 8, text: "Use appropriate tags when submitting your report." },
    ];

    constructor() {
        super(...arguments);
        if(this.args.model) {
            this.initialized = true;
        }

        this.localStorageKey = settings.local_storage_key;

    }

    /**
     * Computed property that checks if any required information is missing.
     * @returns {boolean} True if any required information is missing, false otherwise.
     */
    get hasMissingInformation() {
        return (
            this.args.model.missingDxdiag
            /* this.args.model.missingImage ||
            this.hasMissingLogs ||
            (this.args.model.missingTags && this.args.model.isCreatingTopic) */
        );
    }  /**
     * Computed property that checks if the logs are missing.
     * @returns {boolean} True if the logs are missing, false otherwise.
     */
    get hasMissingLogs() {
        return (
            !this.args.model.logs.playerLog && !this.args.model.logs.playerPrevLog && !this.args.model.logs.datastore
        );
    }

     /**
     * Returns the appropriate icon based on whether the item is missing or not
     * @param {boolean} isMissing - Whether the item is missing
     * @returns {string} The icon name to be used
     */
    getStatusIcon(isMissing) {
        return isMissing ? "exclamation-triangle" : "check-circle";
    }
    
    @action
    closeModalAndSubmit() {
        this.args.model.isShown = false;
        this.args.model.closeModalAndSubmit();
    }

    <template>
        {{#if this.args.model.isShown}}
            <DModal
                @inline={{false}}
                @title="Bug Reporting Guidelines"
                @subtitle="Please read the following carefully"
                @id="bug-info-modal"
                @closeModal={{@closeModal}}
                class="bug-info-modal"
                >
                <:body>
                    <div>

                    {{#if this.hasMissingInformation}}
                     {{dIcon "exclamation-triangle"}} We were unable to find some required information in your post. The missing items are marked in red below:
                    <br>
                    <br>

                    {{/if}}
                        <ul>
                            <li >
                                {{dIcon (this.getStatusIcon @model.missingImage)}}
                                <span class="{{if @model.missingImage "not-found"}}">Attach a picture/video showing the bug.</span>
                            </li>
                            <li>
                                {{dIcon (this.getStatusIcon this.hasMissingLogs)}}
                                <div>
                                    <span class="{{if this.hasMissingLogs "not-found"}}">Include log files:</span>
                                    <ul>
                                        <li><code class="{{if @model.logs.playerLog "hint-found"}}">Player.log</code> and <code class="{{if @model.logs.playerPrevLog "hint-found"}}">Player-prev.log</code></li>
                                        <li>
                                            <code>DataStore</code> folder (as zip file called <code class="{{if @model.logs.datastore "hint-found"}}">DataStore.zip</code>): <br>
                                            <code class="code-inline">%USERPROFILE%\AppData\LocalLow\Moon Studios\NoRestForTheWicked</code>
                                        </li>
                                    </ul>
                                </div>
                            </li>

                            <li>
                                 {{dIcon (this.getStatusIcon @model.missingDxdiag)}}
                                 <div>    
                                    <span class="{{if @model.missingDxdiag "not-found"}}">Include the <em>dxdiag</em> file:</span>
                                    <ul>
                                        <li>Press the Windows key, type <code>dxdiag</code>, and run the program</li>
                                        <li>Click 'Save All Information'</li>
                                        <li>Save the file to a path and attach it to your report</li>
                                    </ul>
                                </div>
                            </li>
                            
                             <li>
                                {{#if this.args.model.isCreatingTopic}}
                                    {{dIcon (this.getStatusIcon @model.missingTags)}}
                                    <span class="{{if @model.missingTags "not-found"}}">Use appropriate tags when submitting your report.</span>
                                {{else}}
                                    {{dIcon "hand-point-right"}} 
                                    <span>Use appropriate tags when submitting your report.</span>
                                {{/if}}
                            </li>

                                 <li>{{dIcon "hand-point-right"}} <span>Respond in English.</span></li>
                            <li>{{dIcon "hand-point-right"}} 
                                
                                <div>
                                    If you experience crashes, include files from: <br>
                                    <code>%USERPROFILE%\AppData\LocalLow\Moon Studios\NoRestForTheWicked\backtrace\crashpad\reports</code>
                                </div>
                            </li>
                            <li>{{dIcon "hand-point-right"}}  <span>Upload these files to an external site (e.g., WeTransfer, Google Drive) and link in your report.</span></li>
                            <li>{{dIcon "hand-point-right"}}  
                                <div>
                                    <span>Answer:</span>
                                    <ul>
                                        <li>Were you able to reproduce the bug?</li>
                                        <li>Where did it occur?</li>
                                        <li>Has it been reported before?</li>
                                    </ul>
                                </div>
                            </li>

                        </ul>
                    </div>
                </:body>
                <:footer>
                    <DButton
                        class="btn-secondary"
                        @icon="times"
                        @translatedLabel="Close"
                        @action={{@closeModal}}
                    />

                    <DButton
                        class="btn-primary"
                        @icon="check"
                        @translatedLabel="Its all there, submit!"
                        @action={{this.closeModalAndSubmit}}
                        @disabled={{this.hasMissingInformation}}
                    />
                </:footer>
            </DModal>
        {{/if}}
    </template>
}