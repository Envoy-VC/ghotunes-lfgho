'use client';

import clsx from 'clsx';
import React from 'react';
import type { IconType } from 'react-icons';

interface Props extends React.ComponentProps<'button'> {
	Icon: IconType;
	extraCls?: string;
}

const ControlButton = ({ Icon, extraCls, ...props }: Props) => {
	return (
		<button {...props}>
			<Icon className={clsx('text-xl text-gray-500', extraCls)} />
		</button>
	);
};

export default ControlButton;
