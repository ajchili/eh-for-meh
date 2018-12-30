package com.kirinpatel.ehformeh.Activities;

import android.animation.ArgbEvaluator;
import android.animation.ValueAnimator;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.support.constraint.ConstraintLayout;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TextView;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.MobileAds;
import com.google.firebase.database.DatabaseError;
import com.kirinpatel.ehformeh.R;
import com.kirinpatel.ehformeh.utils.Deal;
import com.kirinpatel.ehformeh.utils.DealLoader;
import com.kirinpatel.ehformeh.utils.DealLoaderInterface;
import com.kirinpatel.ehformeh.utils.Item;

public class MainActivity extends AppCompatActivity {

    private Deal deal;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        MobileAds.initialize(this, "ca-app-pub-9026572937829340~5362610343");

        AdView AdView = findViewById(R.id.adView);
        AdRequest adRequest = new AdRequest.Builder().build();
        AdView.loadAd(adRequest);

        Toolbar mehToolbar = findViewById(R.id.mehToolbar);
        setSupportActionBar(mehToolbar);

        setupDealListener();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch(item.getItemId()) {
            case R.id.history:
                return true;
            case R.id.forum:
                return true;
            case R.id.Settings:
                Intent intent = new Intent(this, SettingsActivity.class);
                startActivity(intent);
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void animateUI() {
        if (deal == null) return;

        final ConstraintLayout mainLayout = findViewById(R.id.mainLayout);
        final ConstraintLayout bottomSheetLayout = findViewById(R.id.bottomSheetLayout);
        final ConstraintLayout loadingBackground = findViewById(R.id.loadingLayout);
        final TextView loadingTitle = findViewById(R.id.titleTextView);
        final TextView dealTitleTextView = findViewById(R.id.dealTitleTextView);
        final TextView dealPriceTextView = findViewById(R.id.dealPriceTextView);
        final Toolbar mehToolbar = findViewById(R.id.mehToolbar);

        ValueAnimator backgroundColorAnimation = ValueAnimator.ofObject(new ArgbEvaluator(),
                getResources().getColor(R.color.white),
                Color.parseColor(deal.getTheme().getBackgroundColor()));
        backgroundColorAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                loadingBackground.setBackgroundColor((int) animation.getAnimatedValue());
                mainLayout.setBackgroundColor((int) animation.getAnimatedValue());
                mehToolbar.setTitleTextColor((int) animation.getAnimatedValue());
                Menu menu = mehToolbar.getMenu();
                for (int i = 0; i < menu.size(); i++) {
                    Drawable drawable = menu.getItem(i).getIcon();
                    drawable.mutate();
                    drawable.setColorFilter((int) animation.getAnimatedValue(), PorterDuff.Mode.SRC_IN);
                }
            }
        });
        backgroundColorAnimation.setDuration(500);

        int color = Color.TRANSPARENT;
        Drawable accent = bottomSheetLayout.getBackground();
        if (accent instanceof ColorDrawable) color = ((ColorDrawable) accent).getColor();
        ValueAnimator accentColorAnimation = ValueAnimator.ofObject(new ArgbEvaluator(),
                color,
                Color.parseColor(deal.getTheme().getAccentColor()));
        accentColorAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                bottomSheetLayout.setBackgroundColor((int) animation.getAnimatedValue());
                mehToolbar.setBackgroundColor((int) animation.getAnimatedValue());
                dealTitleTextView.setTextColor((int) animation.getAnimatedValue());
                dealPriceTextView.setTextColor((int) animation.getAnimatedValue());
            }
        });
        accentColorAnimation.setDuration(500);


        ValueAnimator titleAlphaAnimation = ValueAnimator.ofFloat(1.0f, 0.0f);
        titleAlphaAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                loadingTitle.setAlpha((float) animation.getAnimatedValue());
            }
        });
        titleAlphaAnimation.setDuration(500);

        ValueAnimator mainLayoutAlphaAnimation = ValueAnimator.ofFloat(0.0f, 1.0f);
        mainLayoutAlphaAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                mainLayout.setAlpha((float) animation.getAnimatedValue());
            }
        });
        mainLayoutAlphaAnimation.setDuration(500);

        backgroundColorAnimation.start();
        accentColorAnimation.start();
        titleAlphaAnimation.start();
        mainLayoutAlphaAnimation.start();
    }

    private void setupDealListener() {
        DealLoader loader = new DealLoader(new DealLoaderInterface() {
            @Override
            public void dealLoaded(Deal loadedDeal) {
                deal = loadedDeal;
                setupView();
                animateUI();
            }

            @Override
            public void dealUpdated(Deal updatedDeal) {
                deal = updatedDeal;
                setupView();
                animateUI();
            }

            @Override
            public void dealLoadFailed(DatabaseError databaseError) {

            }

            @Override
            public void dealNotLoadable(Exception e) {

            }
        });

        loader.watchCurrentDeal();
    }

    private void setupView() {
        if (deal == null) return;

        TextView dealTitleTextView = findViewById(R.id.dealTitleTextView);
        TextView dealPriceTextView = findViewById(R.id.dealPriceTextView);

        dealTitleTextView.setText(deal.getTitle());

        // Calculate price to display in dealPriceTextView
        float minPrice = Float.POSITIVE_INFINITY;
        float maxPrice = Float.NEGATIVE_INFINITY;

        for (Item item : deal.getItems()) {
            if (item.getPrice() < minPrice) minPrice = item.getPrice();
            if (item.getPrice() > maxPrice) maxPrice = item.getPrice();
        }

        String price = "$" + minPrice;
        if (deal.getItems().length > 1 && minPrice != maxPrice) price += " - $" + maxPrice;
        dealPriceTextView.setText(price);
    }
}
