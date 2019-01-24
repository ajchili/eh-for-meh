package com.kirinpatel.ehformeh.Activities;

import android.content.Context;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import com.kirinpatel.ehformeh.R;
import com.kirinpatel.ehformeh.utils.Deal;

import br.tiagohm.markdownview.MarkdownView;
import br.tiagohm.markdownview.css.styles.Github;

public class DealInfo extends AppCompatActivity {

    private static final String KEY_DEAL = "deal";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_deal_info);

        Deal deal = (Deal) getIntent().getSerializableExtra(KEY_DEAL);

        MarkdownView markdownView = findViewById(R.id.markdown_view);
        markdownView.addStyleSheet(new Github());
        markdownView.loadMarkdown(deal.getMarkdownString());
    }

    public static Intent newIntent(Context context, Deal deal) {
        Intent intent = new Intent(context, DealInfo.class);
        intent.putExtra(KEY_DEAL, deal);
        return intent;
    }
}
