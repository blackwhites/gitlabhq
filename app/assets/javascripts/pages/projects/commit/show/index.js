/* eslint-disable no-new */
import Diff from '~/diff';
import ZenMode from '~/zen_mode';
import ShortcutsNavigation from '~/shortcuts_navigation';
import MiniPipelineGraph from '~/mini_pipeline_graph_dropdown';
import initNotes from '~/init_notes';
import initChangesDropdown from '~/init_changes_dropdown';
import { fetchCommitMergeRequests } from '~/commit_merge_requests';

export default () => {
  new Diff();
  new ZenMode();
  new ShortcutsNavigation();
  new MiniPipelineGraph({
    container: '.js-commit-pipeline-graph',
  }).bindEvents();
  initNotes();
  const stickyBarPaddingTop = 16;
  initChangesDropdown(document.querySelector('.navbar-gitlab').offsetHeight - stickyBarPaddingTop);
  $('.commit-info.branches').load(document.querySelector('.js-commit-box').dataset.commitPath);
  fetchCommitMergeRequests();
};
