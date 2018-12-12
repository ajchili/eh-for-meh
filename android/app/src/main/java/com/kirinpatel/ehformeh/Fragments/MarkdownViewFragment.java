package com.kirinpatel.ehformeh.Fragments;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.kirinpatel.ehformeh.R;

import br.tiagohm.markdownview.MarkdownView;
import br.tiagohm.markdownview.css.InternalStyleSheet;
import br.tiagohm.markdownview.css.styles.Github;

public class MarkdownViewFragment extends Fragment {

    private String markdown;
    private static final String MARKDOWN_BUNDLE_ARG = "markdown";

    public static MarkdownViewFragment newInstance(String markdown) {
        MarkdownViewFragment fragment = new MarkdownViewFragment();
        Bundle args = new Bundle();
        args.putString(MARKDOWN_BUNDLE_ARG, markdown);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        markdown = getArguments().getString(MARKDOWN_BUNDLE_ARG);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_markdown_viewer, container, false);

        MarkdownView markdownView = view.findViewById(R.id.markdownView);
        InternalStyleSheet css = new Github();
        css.removeRule (".scrollup");
        markdownView.addStyleSheet(css);
        markdownView.loadMarkdown(markdown);
        markdownView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                v.getParent().requestDisallowInterceptTouchEvent(true);
                return false;
            }
        });

        return view;
    }
}
