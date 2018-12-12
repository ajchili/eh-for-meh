package com.kirinpatel.ehformeh.Adapters;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;

import com.kirinpatel.ehformeh.Fragments.MarkdownViewFragment;
import com.kirinpatel.ehformeh.utils.Deal;

public class BottomSheetPagerAdapter extends FragmentPagerAdapter {

    private Deal deal;

    public BottomSheetPagerAdapter(Deal deal, FragmentManager fragmentManager) {
        super(fragmentManager);

        this.deal = deal;
    }

    @Override
    public Fragment getItem(int position) {
        switch (position) {
            case 0:
                return MarkdownViewFragment.newInstance(deal.getFeatures());
            case 1:
                return MarkdownViewFragment.newInstance(deal.getSpecifications());
            case 2:
                String markdown = new StringBuilder()
                        .append(deal.getStory().getTitle())
                        .append("\n===\n")
                        .append(deal.getStory().getBody())
                        .toString();
                return MarkdownViewFragment.newInstance(markdown);
            default:
                return null;
        }
    }

    @Override
    public int getCount() {
        return 3;
    }

    @Override
    public CharSequence getPageTitle(int position) {
        String[] titles = {"Features", "Specifications", "Story"};
        return titles[position];
    }
}
