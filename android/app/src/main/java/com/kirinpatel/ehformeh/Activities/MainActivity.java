package com.kirinpatel.ehformeh.Activities;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ArgbEvaluator;
import android.animation.ValueAnimator;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.support.constraint.ConstraintLayout;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.google.firebase.database.DatabaseError;
import com.kirinpatel.ehformeh.R;
import com.kirinpatel.ehformeh.utils.Deal;
import com.kirinpatel.ehformeh.utils.DealLoader;
import com.kirinpatel.ehformeh.utils.DealLoaderInterface;

public class MainActivity extends AppCompatActivity {

    private Deal deal;
    private boolean hasAnimated = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        setupDealListener();
    }

    private void animateUI() {
        if (deal != null && !hasAnimated) {
            hasAnimated = true;
            final ConstraintLayout loadingBackground = findViewById(R.id.loadingLayout);
            final ConstraintLayout mainLayout = findViewById(R.id.mainLayout);
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
        } else if (deal != null) {
            final ConstraintLayout mainLayout = findViewById(R.id.mainLayout);

            int color = Color.TRANSPARENT;
            Drawable background = mainLayout.getBackground();
            if (background instanceof ColorDrawable) color = ((ColorDrawable) background).getColor();
            ValueAnimator backgroundColorAnimation = ValueAnimator.ofObject(new ArgbEvaluator(),
                    color,
                    Color.parseColor(deal.getTheme().getBackgroundColor()));
            backgroundColorAnimation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator animation) {
                    mainLayout.setBackgroundColor((int) animation.getAnimatedValue());
                }
            });
            backgroundColorAnimation.setDuration(500);

            backgroundColorAnimation.start();
        }
    }

    private void setupDealListener() {
        DealLoader loader = new DealLoader(new DealLoaderInterface() {
            @Override
            public void dealLoaded(Deal loadedDeal) {
                deal = loadedDeal;
                animateUI();
            }

            @Override
            public void dealUpdated(Deal updatedDeal) {
                deal = updatedDeal;
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

    }
}
