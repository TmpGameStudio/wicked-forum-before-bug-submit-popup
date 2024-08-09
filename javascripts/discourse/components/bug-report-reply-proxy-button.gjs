// components/heart-button.gjs
import {tracked} from "@glimmer/tracking";
import {action} from "@ember/object";
import {inject as service} from "@ember/service";
import DButton from "discourse/components/d-button";
import PostTextSelection from "discourse/components/post-text-selection";
import BugReportInstructionsModal from "./bug-report-instructions-modal";
import {getOwner} from "@ember/application";
import Component from "@glimmer/component";

export default class BugReportReplyProxyButton extends Component {
    @service modal;
    @service siteSettings;

    localStorageKey = undefined;
    wickedBugsCategoryId = undefined;

    @tracked _showProxyReplyButton = false;

    constructor() {
        super(...arguments);

        this.localStorageKey = settings.local_storage_key;
        this.wickedBugsCategoryId = settings.wicked_bugs_category_id;

       if(!this.isWickedBugsCategory()) {
            return;
       }

        if(this.userDismissedInstructions()) {
            return;
        }

        this.toggleShowProxyReplyButton(true);
        setTimeout(() => {
            this.toggleMainReplyButton(false);
        }, 1);
    }


    <template>
         {{#if this._showProxyReplyButton}}
            <DButton
                @action={{this.onProxyReplyClicked}}
                @icon="reply"  
                @translatedLabel="Reply"
                class="btn-primary"
            />
        {{/if}}
    </template>

    /**
     * Toggles the visibility of the main reply button.
     * @param {boolean} show - Whether to show or hide the button.
     */
    @action
    toggleMainReplyButton(show) {
        const button = document.querySelector('#reply-control .save-or-cancel .btn-primary');
        if (button) {
            button.style.display = show ? 'block' : 'none';
        }
    }

    /**
     * Toggles the visibility of the proxy reply button.
     */
    @action
    toggleShowProxyReplyButton() {
        this._showProxyReplyButton = !this._showProxyReplyButton;
    }


    @action
    onProxyReplyClicked() {
        this.modal.show(BugReportInstructionsModal, {
            model: {
                initialValue: false,
                isShown: true,
            }
        });

        this.toggleMainReplyButton(true);
        this.toggleShowProxyReplyButton(false);
    }

    userDismissedInstructions() {
        return localStorage.getItem(this.localStorageKey) === 'true';
    }

    isWickedBugsCategory() {
        const topicController = getOwner(this).lookup("controller:topic");
        return topicController.model.category_id === this.wickedBugsCategoryId;
    }
}