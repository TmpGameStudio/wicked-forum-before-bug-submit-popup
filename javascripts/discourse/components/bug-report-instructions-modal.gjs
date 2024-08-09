import Component from "@glimmer/component";
import {tracked} from "@glimmer/tracking";
import { on } from "@ember/modifier";
import {action} from "@ember/object";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import DToggleSwitch from "discourse/components/d-toggle-switch";

export default class BugReportInstructionsModal extends Component {
    @service siteSettings;
    
    @tracked dontShowAgain = false;

    localStorageKey = undefined;

    constructor() {
        super(...arguments);
        if(this.args.model) {
            this.initialized = true;
        }

        this.localStorageKey = settings.local_storage_key;
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
                        <ul>
                            <li>Respond in English.</li>
                            <li>Attach a picture/video showing the bug.</li>
                            <li>Include log files:
                            <ul>
                                <li><code>Player.log</code> and <code>Player-prev.log</code></li>
                                <li><code>DataStore</code> folder: <br>
                                <code>%USERPROFILE%\AppData\LocalLow\Moon Studios\NoRestForTheWicked</code></li>
                            </ul>
                            </li>
                            <li>If you experience crashes, include files from: <br>
                            <code>%USERPROFILE%\AppData\LocalLow\Moon Studios\NoRestForTheWicked\backtrace\crashpad\reports</code></li>
                            <li>Include the <code>dxdiag</code> file:
                            <ul>
                                <li>Press the Windows key, type <code>dxdiag</code>, and run the program</li>
                                <li>Click ‘Save All Information’</li>
                                <li>Save the file to a path</li>
                            </ul>
                            </li>
                            <li>Upload these files to an external site (e.g., WeTransfer, Google Drive) and link in your report.</li>
                            <li>Answer:
                            <ul>
                                <li>Were you able to reproduce the bug?</li>
                                <li>Where did it occur?</li>
                                <li>Has it been reported before?</li>
                            </ul>
                            </li>
                            <li>Use appropriate tags when submitting your report.</li>
                        </ul>
                    </div>

                    <div>
                        <DToggleSwitch
                            @state={{this.dontShowAgain}}
                            @translatedLabel="Do not show again"
                            {{on "click" this.toggleDontShowAgain}}
                        />

                    </div>
                </:body>
                <:footer>
                    <DButton
                        class="btn-primary"
                        @icon="check"
                        @translatedLabel="Close"
                        @action={{@closeModal}}
                    />
                </:footer>
            </DModal>
        {{/if}}
    </template>

    /**
     * Toggles the user's preference to show or hide the bug submit instructions.
     * This method sets a flag in localStorage to indicate whether the popup should be shown in future.
     */
    @action
    toggleDontShowAgain() {
        this.dontShowAgain = !this.dontShowAgain;
        localStorage.setItem(this.localStorageKey, this.dontShowAgain.toString());
    }
}