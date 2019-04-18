package com.kirinpatel.ehformeh.Activities;

import android.content.Context;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;

import com.google.firebase.database.DatabaseError;
import com.kirinpatel.ehformeh.R;
import com.kirinpatel.ehformeh.utils.Deal;
import com.kirinpatel.ehformeh.utils.DealLoader;
import com.kirinpatel.ehformeh.utils.DealLoaderInterface;

import br.tiagohm.markdownview.MarkdownView;
import br.tiagohm.markdownview.css.styles.Github;

public class DealInfo extends AppCompatActivity {

    private static final String KEY_DEAL_ID = "dealId";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_deal_info);

        if (getIntent().getStringExtra(KEY_DEAL_ID) != null) {

        } else {
            new DealLoader(new DealLoaderInterface() {
                @Override
                public void dealLoaded(Deal deal) {
                    MarkdownView markdownView = findViewById(R.id.markdown_view);
                    markdownView.addStyleSheet(new Github());
                    markdownView.loadMarkdown(deal.getMarkdownString());
                }

                @Override
                public void dealUpdated(Deal deal) {

                }

                @Override
                public void dealLoadFailed(DatabaseError databaseError) {

                }

                @Override
                public void dealNotLoadable(Exception e) {

                }
            }).loadCurrentDeal();
        }
    }

    public static Intent newIntent(Context context) {
        return new Intent(context, DealInfo.class);
    }

    public static Intent newIntent(Context context, String id) {
        Intent intent = new Intent(context, DealInfo.class);
        intent.putExtra(KEY_DEAL_ID, id);
        return intent;
    }
}
