package com.kirinpatel.ehformeh.Activities;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ArgbEvaluator;
import android.animation.ValueAnimator;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Point;
import android.net.Uri;
import android.support.constraint.ConstraintLayout;
import android.support.v4.view.PagerTabStrip;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.Display;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.firebase.database.DatabaseError;
import com.kirinpatel.ehformeh.Adapters.BottomSheetPagerAdapter;
import com.kirinpatel.ehformeh.R;
import com.kirinpatel.ehformeh.utils.Deal;
import com.kirinpatel.ehformeh.utils.DealLoader;
import com.kirinpatel.ehformeh.utils.DealLoaderInterface;
import com.kirinpatel.ehformeh.utils.Item;
import com.pierfrancescosoffritti.slidingdrawer.SlidingDrawer;

import java.net.URISyntaxException;

public class MainActivity extends AppCompatActivity {

    private Deal deal;
    private boolean hasAnimated = false;

    private SlidingDrawer mainLayout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mainLayout = findViewById(R.id.mainLayout);
        setupSlidingView();
        setupCurrentDealListener();
    }

    private void setupViewPager() {
        ViewPager viewPager = findViewById(R.id.viewPager);
        BottomSheetPagerAdapter adapter = new BottomSheetPagerAdapter(deal, getSupportFragmentManager());
        viewPager.setAdapter(adapter);

        Button buyButton = findViewById(R.id.buyDealButton);
        buyButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse(deal.getURL().toString()));
                startActivity(intent);
            }
        });
    }

    private void setupSlidingView() {
        mainLayout.setDragView(findViewById(R.id.slidableViewContent));
        findViewById(R.id.dealInfoTextView).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mainLayout.slideTo(mainLayout.getState() == SlidingDrawer.EXPANDED ? 0 : 1);
            }
        });
        calculateScreenHeight();
    }

    private void calculateScreenHeight() {
        ConstraintLayout contentView = findViewById(R.id.contentView);
        ViewGroup.LayoutParams params = contentView.getLayoutParams();

        Display display = getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        params.height = (int) (size.y * .85);

        contentView.setLayoutParams(new LinearLayout.LayoutParams(params));
    }

    private void animateStart() {
        if (deal != null && !hasAnimated) {
            hasAnimated = true;
            final ConstraintLayout loadingBackground = findViewById(R.id.loadingLayout);
            final ConstraintLayout slidingView = findViewById(R.id.slidableViewContent);
            final TextView loadingTitle = findViewById(R.id.titleTextView);

            ValueAnimator backgroundColorAnimation = ValueAnimator.ofObject(new ArgbEvaluator(),
                    getResources().getColor(R.color.white),
                    Color.parseColor(deal.getTheme().getBackgroundColor()));
            backgroundColorAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animation) {
                    loadingBackground.setBackgroundColor((int) animation.getAnimatedValue());
                }
            });
            backgroundColorAnimation.setDuration(500);

            ValueAnimator titleAlphaAnimation = ValueAnimator.ofFloat(1.0f, 0.0f);
            titleAlphaAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animation) {
                    loadingTitle.setAlpha((float) animation.getAnimatedValue());
                }
            });
            titleAlphaAnimation.setDuration(500);

            backgroundColorAnimation.start();
            titleAlphaAnimation.start();

            titleAlphaAnimation.addListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationCancel(Animator animation) {
                    super.onAnimationCancel(animation);
                }

                @Override
                public void onAnimationEnd(Animator animation) {
                    super.onAnimationEnd(animation);

                    loadingBackground.setVisibility(View.GONE);
                    mainLayout.setBackgroundColor(Color.parseColor(deal.getTheme().getBackgroundColor()));
                    mainLayout.setVisibility(View.VISIBLE);
                    slidingView.setBackgroundColor(Color.parseColor(deal.getTheme().getAccentColor()));
                }

                @Override
                public void onAnimationRepeat(Animator animation) {
                    super.onAnimationRepeat(animation);
                }

                @Override
                public void onAnimationStart(Animator animation) {
                    super.onAnimationStart(animation);
                }

                @Override
                public void onAnimationPause(Animator animation) {
                    super.onAnimationPause(animation);
                }

                @Override
                public void onAnimationResume(Animator animation) {
                    super.onAnimationResume(animation);
                }
            });
        }
    }

    private void setupCurrentDealListener() {
        DealLoader loader = new DealLoader(new DealLoaderInterface() {
            @Override
            public void dealLoaded(Deal loadedDeal) {
                deal = loadedDeal;

                animateStart();
                updateUIWithCurrentDeal();
                setupViewPager();
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
        });
        loader.loadCurrentDeal();
    }

    private void updateUIWithCurrentDeal() {
        if (deal != null) {
            // Title
            TextView dealTitle = findViewById(R.id.dealTitleTextView);
            dealTitle.setText(deal.getTitle());
            dealTitle.setTextColor(Color.parseColor(deal.getTheme().getAccentColor()));

            // Price
            TextView dealPrice = findViewById(R.id.dealPriceTextView);
            Float minPrice = Float.MAX_VALUE;
            Float maxPrice = Float.MIN_VALUE;
            for (Item item : deal.getItems()) {
                Float price = item.getPrice();
                if (price < minPrice) minPrice = price;
                if (price > maxPrice) maxPrice = price;
            }
            String price = "$" + minPrice;
            if (maxPrice != minPrice) price += " - $" + maxPrice;
            dealPrice.setText(price);

            // Deal Info
            TextView dealInfo = findViewById(R.id.dealInfoTextView);
            dealInfo.setTextColor(Color.parseColor(deal.getTheme().getBackgroundColor()));

            // View Pager
            PagerTabStrip tabStrip = findViewById(R.id.viewPagerTabs);
            tabStrip.setTabIndicatorColor(Color.parseColor(deal.getTheme().getBackgroundColor()));
            tabStrip.setTextColor(Color.parseColor(deal.getTheme().getBackgroundColor()));
        }
    }
}
